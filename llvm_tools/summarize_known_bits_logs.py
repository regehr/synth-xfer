#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from collections import Counter, defaultdict
from pathlib import Path


# Map known LLVM log instruction names to mlir/Operations/<Name>.mlir stems.
LLVM_NAME_TO_MLIR_STEM: dict[str, str] = {
    "add": "Add",
    "add.nsw": "AddNsw",
    "add.nsw.nuw": "AddNswNuw",
    "add.nuw": "AddNuw",
    "and": "And",
    "ashr": "Ashr",
    "ashr.exact": "AshrExact",
    "lshr": "Lshr",
    "lshr.exact": "LshrExact",
    "mul": "Mul",
    "mul.nsw": "MulNsw",
    "mul.nsw.nuw": "MulNswNuw",
    "mul.nuw": "MulNuw",
    "or": "Or",
    "sdiv": "Sdiv",
    "sdiv.exact": "SdivExact",
    "shl": "Shl",
    "shl.nsw": "ShlNsw",
    "shl.nsw.nuw": "ShlNswNuw",
    "shl.nuw": "ShlNuw",
    "srem": "Mods",
    "sub": "Sub",
    "sub.nsw": "SubNsw",
    "sub.nsw.nuw": "SubNswNuw",
    "sub.nuw": "SubNuw",
    "udiv": "Udiv",
    "udiv.exact": "UdivExact",
    "urem": "Modu",
    "xor": "Xor",
}

# Intrinsics in logs include overload suffixes, e.g. llvm.umin.i64.
LLVM_INTRINSIC_PREFIX_TO_MLIR_STEM: dict[str, str] = {
    "llvm.ctlz": "CountLZero",
    "llvm.cttz": "CountRZero",
    "llvm.ctpop": "PopCount",
    "llvm.fshl": "Fshl",
    "llvm.fshr": "Fshr",
    "llvm.smax": "Smax",
    "llvm.smin": "Smin",
    "llvm.umax": "Umax",
    "llvm.umin": "Umin",
    "llvm.sadd.sat": "SaddSat",
    "llvm.uadd.sat": "UaddSat",
    "llvm.ssub.sat": "SsubSat",
    "llvm.usub.sat": "UsubSat",
    "llvm.sshl.sat": "SshlSat",
    "llvm.ushl.sat": "UshlSat",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Aggregate known-bits logs per instruction and bitwidth. "
            "For each (instruction, width), emit total unknown result bits "
            "and input-pattern counts."
        )
    )
    parser.add_argument("files", nargs="+", type=Path, help="Known-bits log files to process")
    return parser.parse_args()


def sanitize_insn_for_filename(insn: str) -> str:
    return insn.replace("/", "_")


def map_llvm_insn_to_mlir_stem(insn: str) -> str:
    direct = LLVM_NAME_TO_MLIR_STEM.get(insn)
    if direct is not None:
        return direct

    for prefix, stem in LLVM_INTRINSIC_PREFIX_TO_MLIR_STEM.items():
        if insn == prefix or insn.startswith(prefix + "."):
            return stem

    # Keep unknown names stable and filesystem-safe.
    return sanitize_insn_for_filename(insn)


def main() -> int:
    args = parse_args()

    # Keyed by (instruction_name, result_bitwidth).
    unknown_bits_by_bucket: Counter[tuple[str, int]] = Counter()
    input_patterns_by_bucket: dict[tuple[str, int], Counter[str]] = defaultdict(Counter)

    for path in args.files:
        try:
            with path.open("r", encoding="utf-8") as infile:
                for lineno, line in enumerate(infile, start=1):
                    stripped = line.strip()
                    if not stripped:
                        continue

                    parts = stripped.split()
                    if len(parts) < 3:
                        print(
                            f"warning: skipping malformed line {path}:{lineno}: {stripped}",
                            file=sys.stderr,
                        )
                        continue

                    llvm_insn = parts[0]
                    result = parts[1]
                    inputs = parts[2:]

                    insn = map_llvm_insn_to_mlir_stem(llvm_insn)
                    width = len(result)
                    bucket = (insn, width)

                    unknown_bits_by_bucket[bucket] += result.count("?")
                    input_patterns_by_bucket[bucket][" ".join(inputs)] += 1
        except FileNotFoundError:
            print(f"error: file not found: {path}", file=sys.stderr)
            return 1

    output_dir = Path("output2")
    output_dir.mkdir(exist_ok=True)

    for insn, width in sorted(unknown_bits_by_bucket, key=lambda item: (item[0], item[1])):
        file_insn = sanitize_insn_for_filename(insn)
        out_file = output_dir / f"KnownBits_{file_insn}_{width}.txt"

        with out_file.open("w", encoding="utf-8") as outfile:
            outfile.write(f"unknown_result_bits\t{unknown_bits_by_bucket[(insn, width)]}\n")
            for pattern, count in sorted(
                input_patterns_by_bucket[(insn, width)].items(),
                key=lambda item: (-item[1], item[0]),
            ):
                outfile.write(f"{count}\t{pattern}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
