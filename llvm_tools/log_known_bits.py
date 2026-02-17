#!/usr/bin/env python3

from pathlib import Path
import subprocess


OPT = "/home/regehr/llvm-project-regehr/build/bin/opt"


def main() -> None:
    output_dir = Path("output")
    output_dir.mkdir(exist_ok=True)

    for index, path in enumerate(sorted(Path(".").glob("bench/*/optimized/*.ll"))):
        log_file = output_dir / f"{index}_{path.stem}.log"
        if log_file.exists():
            print(f"skipping {path} (exists: {log_file})", flush=True)
            continue
        print(path, flush=True)
        subprocess.run(
            [
                OPT,
                "-O2",
                "-disable-output",
                "-non-global-value-max-name-size",
                "4096",
                "-known-bits-log-file",
                str(log_file),
                str(path),
            ],
            check=True,
        )


if __name__ == "__main__":
    main()
