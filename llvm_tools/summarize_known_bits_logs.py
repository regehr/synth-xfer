#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from collections import Counter, defaultdict
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Aggregate known-bits logs per instruction. "
            "For each instruction, emit total unknown result bits and input-pattern counts."
        )
    )
    parser.add_argument("files", nargs="+", type=Path, help="Known-bits log files to process")
    return parser.parse_args()


def sanitize_insn_for_filename(insn: str) -> str:
    return insn.replace("/", "_")


def main() -> int:
    args = parse_args()

    unknown_bits_by_insn: Counter[str] = Counter()
    input_patterns_by_insn: dict[str, Counter[str]] = defaultdict(Counter)

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

                    insn = parts[0]
                    result = parts[1]
                    inputs = parts[2:]

                    unknown_bits_by_insn[insn] += result.count("?")
                    input_patterns_by_insn[insn][" ".join(inputs)] += 1
        except FileNotFoundError:
            print(f"error: file not found: {path}", file=sys.stderr)
            return 1

    output_dir = Path("output2")
    output_dir.mkdir(exist_ok=True)

    for insn in sorted(unknown_bits_by_insn):
        file_insn = sanitize_insn_for_filename(insn)

        result_file = output_dir / f"llvm_result_{file_insn}.txt"
        result_file.write_text(f"{unknown_bits_by_insn[insn]}\n", encoding="utf-8")

        inputs_file = output_dir / f"inputs_{file_insn}.txt"
        with inputs_file.open("w", encoding="utf-8") as outfile:
            for pattern, count in sorted(
                input_patterns_by_insn[insn].items(), key=lambda item: (-item[1], item[0])
            ):
                outfile.write(f"{count}\t{pattern}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
