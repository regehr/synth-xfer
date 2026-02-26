#!/usr/bin/env python3

import argparse
import re
import sys
from collections import defaultdict

SKIP_INSTRUCTIONS = {"sext", "zext", "trunc"}
TYPE_SUFFIX_RE = re.compile(r"\.(?:i\d+|v\d+i\d+)$")


def normalize_instruction(name: str) -> str:
    return TYPE_SUFFIX_RE.sub("", name)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Check that every (instruction, input-args) pair maps to a unique "
            "result across all provided files treated as one dataset."
        )
    )
    parser.add_argument("files", nargs="+", help="Input files to scan")
    parser.add_argument(
        "--max-report",
        type=int,
        default=20,
        help="Maximum number of inconsistent mappings to print (default: 20)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    results_by_key = defaultdict(set)
    malformed = 0
    total_lines = 0
    parsed_lines = 0
    skipped_lines = 0

    for path in args.files:
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                for line_no, line in enumerate(f, start=1):
                    total_lines += 1
                    line = line.strip()
                    if not line:
                        continue

                    parts = line.split()
                    if len(parts) < 2:
                        malformed += 1
                        print(
                            f"warning: malformed line skipped: {path}:{line_no}",
                            file=sys.stderr,
                        )
                        continue

                    inst = normalize_instruction(parts[0])
                    if inst in SKIP_INSTRUCTIONS:
                        skipped_lines += 1
                        continue

                    result = parts[1]
                    inputs = tuple(parts[2:])
                    results_by_key[(inst, inputs)].add(result)
                    parsed_lines += 1
        except OSError as e:
            print(f"error: could not read {path}: {e}", file=sys.stderr)
            return 2

    inconsistencies = [
        (inst, inputs, sorted(results))
        for (inst, inputs), results in results_by_key.items()
        if len(results) > 1
    ]
    inconsistencies.sort(key=lambda item: (-len(item[2]), item[0], item[1]))

    print(f"files: {len(args.files)}")
    print(f"total_lines: {total_lines}")
    print(f"parsed_lines: {parsed_lines}")
    print(f"skipped_lines: {skipped_lines}")
    print(f"unique_keys: {len(results_by_key)}")
    if malformed:
        print(f"malformed_lines: {malformed}")

    if not inconsistencies:
        print("status: consistent")
        return 0

    print(f"status: inconsistent ({len(inconsistencies)} mappings)")
    print(
        "rule: for each normalized instruction and input tuple, "
        "result must be unique"
    )

    limit = args.max_report if args.max_report >= 0 else 0
    for i, (inst, inputs, results) in enumerate(inconsistencies[:limit], start=1):
        args_text = " ".join(inputs) if inputs else "<no-args>"
        results_text = ", ".join(results)
        print(f"{i}. instruction={inst}")
        print(f"   inputs={args_text}")
        print(f"   results={results_text}")

    remaining = len(inconsistencies) - limit
    if remaining > 0:
        print(f"... {remaining} more inconsistent mappings not shown")

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
