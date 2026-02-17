#!/usr/bin/env python3
"""Run a command under a memory cap on macOS without privileged tools.

This wrapper monitors the child process with libproc's proc_pid_rusage and
kills it when resident memory exceeds the given threshold.
"""

from __future__ import annotations

import argparse
import ctypes
import os
import signal
import subprocess
import sys
import time
from typing import Sequence


# From <libproc.h>
RUSAGE_INFO_V2 = 2


class RusageInfoV2(ctypes.Structure):
    _fields_ = [
        ("ri_uuid", ctypes.c_uint8 * 16),
        ("ri_user_time", ctypes.c_uint64),
        ("ri_system_time", ctypes.c_uint64),
        ("ri_pkg_idle_wkups", ctypes.c_uint64),
        ("ri_interrupt_wkups", ctypes.c_uint64),
        ("ri_pageins", ctypes.c_uint64),
        ("ri_wired_size", ctypes.c_uint64),
        ("ri_resident_size", ctypes.c_uint64),
        ("ri_phys_footprint", ctypes.c_uint64),
        ("ri_proc_start_abstime", ctypes.c_uint64),
        ("ri_proc_exit_abstime", ctypes.c_uint64),
    ]


UNIT_MULTIPLIERS = {
    "": 1,
    "b": 1,
    "k": 1024,
    "kb": 1024,
    "m": 1024 * 1024,
    "mb": 1024 * 1024,
    "g": 1024 * 1024 * 1024,
    "gb": 1024 * 1024 * 1024,
    "t": 1024 * 1024 * 1024 * 1024,
    "tb": 1024 * 1024 * 1024 * 1024,
}


def _format_bytes(value: int) -> str:
    units = ["B", "KiB", "MiB", "GiB", "TiB"]
    n = float(value)
    idx = 0
    while n >= 1024.0 and idx < len(units) - 1:
        n /= 1024.0
        idx += 1
    return f"{n:.1f}{units[idx]}"


def parse_bytes(text: str) -> int:
    import re

    m = re.fullmatch(r"\s*(\d+(?:\.\d+)?)\s*([a-zA-Z]{0,2})\s*", text)
    if not m:
        raise argparse.ArgumentTypeError("limit must look like 512M, 2G, or bytes")

    number = float(m.group(1))
    unit = m.group(2).lower()
    if unit not in UNIT_MULTIPLIERS:
        raise argparse.ArgumentTypeError(
            f"unsupported unit '{unit}' (use B/K/M/G/T, optional B suffix)"
        )

    value = int(number * UNIT_MULTIPLIERS[unit])
    if value <= 0:
        raise argparse.ArgumentTypeError("limit must be > 0")
    return value


def _libproc_proc_pid_rusage() -> ctypes._CFuncPtr:
    libproc = ctypes.CDLL("libproc.dylib", use_errno=True)
    fn = libproc.proc_pid_rusage
    fn.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_void_p]
    fn.restype = ctypes.c_int
    return fn


def _libproc_proc_listchildpids() -> ctypes._CFuncPtr:
    libproc = ctypes.CDLL("libproc.dylib", use_errno=True)
    fn = libproc.proc_listchildpids
    fn.argtypes = [ctypes.c_int, ctypes.c_void_p, ctypes.c_int]
    fn.restype = ctypes.c_int
    return fn


def get_pid_phys_footprint_bytes(proc_pid_rusage: ctypes._CFuncPtr, pid: int) -> int:
    info = RusageInfoV2()
    rc = proc_pid_rusage(pid, RUSAGE_INFO_V2, ctypes.byref(info))
    if rc != 0:
        errno_value = ctypes.get_errno()
        raise OSError(errno_value, os.strerror(errno_value))
    return int(info.ri_phys_footprint)


def list_child_pids(proc_listchildpids: ctypes._CFuncPtr, ppid: int) -> list[int]:
    cap = 64
    while True:
        buf = (ctypes.c_int * cap)()
        n = proc_listchildpids(ppid, ctypes.byref(buf), ctypes.sizeof(buf))
        if n < 0:
            errno_value = ctypes.get_errno()
            raise OSError(errno_value, os.strerror(errno_value))
        if n < cap:
            return [int(buf[i]) for i in range(n) if int(buf[i]) > 0]
        cap *= 2


def collect_process_tree_pids(proc_listchildpids: ctypes._CFuncPtr, root_pid: int) -> list[int]:
    seen = {root_pid}
    stack = [root_pid]
    while stack:
        pid = stack.pop()
        try:
            children = list_child_pids(proc_listchildpids, pid)
        except OSError:
            continue
        for child in children:
            if child not in seen:
                seen.add(child)
                stack.append(child)
    return sorted(seen)


def get_tree_phys_footprint_bytes(
    proc_pid_rusage: ctypes._CFuncPtr,
    proc_listchildpids: ctypes._CFuncPtr,
    root_pid: int,
) -> tuple[int, list[int]]:
    pids = collect_process_tree_pids(proc_listchildpids, root_pid)
    total = 0
    for pid in pids:
        try:
            total += get_pid_phys_footprint_bytes(proc_pid_rusage, pid)
        except OSError:
            continue
    return total, pids


def _send_signal(pid: int, sig: int) -> None:
    try:
        os.kill(pid, sig)
    except (ProcessLookupError, PermissionError):
        return


def terminate_tree(
    proc_listchildpids: ctypes._CFuncPtr,
    root_pid: int,
    grace_seconds: float,
) -> None:
    pids = collect_process_tree_pids(proc_listchildpids, root_pid)
    for pid in reversed(pids):
        _send_signal(pid, signal.SIGTERM)

    deadline = time.monotonic() + grace_seconds
    while time.monotonic() < deadline:
        survivors = []
        for pid in pids:
            try:
                os.kill(pid, 0)
                survivors.append(pid)
            except (ProcessLookupError, PermissionError):
                continue
        if not survivors:
            return
        pids = survivors
        time.sleep(0.02)

    for pid in reversed(pids):
        _send_signal(pid, signal.SIGKILL)


def run_with_limit(
    command: Sequence[str],
    limit_bytes: int,
    interval_seconds: float,
    grace_seconds: float,
    verbose: bool,
) -> int:
    proc_pid_rusage = _libproc_proc_pid_rusage()
    proc_listchildpids = _libproc_proc_listchildpids()
    child = subprocess.Popen(command, start_new_session=True)
    peak_bytes = 0

    while True:
        exit_code = child.poll()

        if exit_code is not None:
            if verbose:
                print(f"memlimit: peak memory observed: {_format_bytes(peak_bytes)}", file=sys.stderr)
            return exit_code

        try:
            mem_bytes, pids = get_tree_phys_footprint_bytes(
                proc_pid_rusage,
                proc_listchildpids,
                child.pid,
            )
            peak_bytes = max(peak_bytes, mem_bytes)
        except OSError:
            # Process likely exited between poll and sample.
            continue

        if mem_bytes > limit_bytes:
            print(
                (
                    "memlimit: limit exceeded: "
                    f"phys_footprint={_format_bytes(mem_bytes)} > "
                    f"limit={_format_bytes(limit_bytes)} "
                    f"(root_pid={child.pid}, pids={','.join(str(p) for p in pids)})"
                ),
                file=sys.stderr,
            )
            terminate_tree(proc_listchildpids, child.pid, grace_seconds)
            child.wait()
            if verbose:
                print(f"memlimit: peak memory observed: {_format_bytes(peak_bytes)}", file=sys.stderr)
            return 137

        time.sleep(interval_seconds)


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    if "--" in argv:
        sep = argv.index("--")
        option_argv = list(argv[:sep])
        command = list(argv[sep + 1 :])
    else:
        option_argv = list(argv)
        command = []

    parser = argparse.ArgumentParser(
        description=(
            "Run a command and kill it if memory goes above LIMIT. "
            "Example: memlimit.py 2G -- my_command arg1"
        )
    )
    parser.add_argument("limit", type=parse_bytes, help="Memory limit (e.g., 512M, 2G)")
    parser.add_argument(
        "--interval-ms",
        type=int,
        default=20,
        help="Polling interval in milliseconds (default: 20)",
    )
    parser.add_argument(
        "--grace-ms",
        type=int,
        default=500,
        help="Grace period before SIGKILL after SIGTERM (default: 500)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print peak memory usage",
    )

    args = parser.parse_args(option_argv)

    if args.interval_ms <= 0:
        parser.error("--interval-ms must be > 0")
    if args.grace_ms < 0:
        parser.error("--grace-ms must be >= 0")
    if not command:
        parser.error("missing command after --")

    args.command = command
    return args


def main(argv: Sequence[str]) -> int:
    args = parse_args(argv)
    return run_with_limit(
        command=args.command,
        limit_bytes=args.limit,
        interval_seconds=args.interval_ms / 1000.0,
        grace_seconds=args.grace_ms / 1000.0,
        verbose=args.verbose,
    )


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
