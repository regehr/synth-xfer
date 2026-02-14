# KnownBits Transfer Function Playbook (`<OP>`)

Implement or improve a KnownBits transfer function for operation `<OP>` in this repo.

## Key Clarifications

- CI integration is **not required** for this task.
- The primary tools are `verify` and `final-eval`.
- `final-eval` must always be run with these exact arguments: `--exact-bw 8,1000 --norm-bw 64,10000,1000`.
- The width list below is only a suggestion; choose widths freely to maximize useful signal.
- In addition to implementing/testing the transfer, you may optionally suggest concrete `transfer` dialect integer operations that are missing and would enable a more precise or more efficient transformer.

## Requirements

1. Implement `tests/data/kb_<op>.mlir` in the same MLIR style as:
   - `tests/data/kb_and.mlir`
   - `tests/data/kb_or.mlir`
   - `tests/data/kb_xor.mlir`
2. Use symbol name `kb_<op>` and this exact function signature:

```mlir
(!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
```

3. KnownBits encoding:
   - index `0` = known-zero mask
   - index `1` = known-one mask
4. Transfer must be **sound** and as **precise** as possible.
5. Keep code bitwidth-agnostic:
   - no special cases for specific bitwidths (for example, no `if bw == ...` logic)
6. Keep solver timeout at or below **60 seconds**.
7. Keep changes minimal and repo-consistent.
8. Reuse existing transfer primitives where possible:
   - `transfer.and`
   - `transfer.or`
   - `transfer.xor`
   - `transfer.add`
   - `transfer.sub`
   - `transfer.shl`
   - `transfer.lshr`
   - `transfer.constant`
   - `transfer.get_all_ones`
   - etc.

## SSA IR Discipline (Important)

- This MLIR parser uses strict SSA form: every `%name = ...` must be the result of an operation.
- Do **not** write alias assignments like `%x = %y : !transfer.integer` (invalid syntax here).
- If you only need another reference, reuse the original SSA value directly instead of creating an alias.
- After drafting a new transfer file, run a quick one-width `verify` first to catch parser/syntax issues early, then run broader widths.

## Testing Guidance

- Use `verify` as the soundness oracle.
- Use `final-eval` as the precision/quality metric.
- You may choose any widths (examples: `4, 8, 16, 24, 32, 40, 48`).
- Prefer testing widths separately (and in parallel if convenient) so one slow width does not block all results.

## Command Templates

```bash
verify --xfer-file tests/data/kb_<op>.mlir --bw <chosen-widths> --timeout 60 --domain KnownBits --op mlir/Operations/<Op>.mlir
```

```bash
final-eval tests/data/kb_<op>.mlir --domain KnownBits --op mlir/Operations/<Op>.mlir --exact-bw 8,1000 --norm-bw 64,10000,1000
```

## Optional Test File Updates (Only If Asked)

- `tests/test_verif.py`: add/update `test_verif_kb_<op>()`
- `tests/test_jit.py`: add/update `test_jit_with_kb_<op>()`

## Required Return Format

1. Files changed.
2. Soundness results per tested bitwidth (`sound` / `unsound` / `timeout` + runtime).
3. `final-eval` table values (run with `--exact-bw 8,1000 --norm-bw 64,10000,1000`).
4. Precision/soundness caveats, clearly separating `timeout/unresolved` from `unsound`.
