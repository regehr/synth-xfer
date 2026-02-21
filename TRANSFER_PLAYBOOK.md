# Transfer Function Playbook (`<DOMAIN>`, `<OP>`)

Implement or improve one transfer function in this repo.

## Scope Per Task (Hard Rule)

- Work on exactly one abstract domain and one operation at a time.
- Allowed domains: `KnownBits`, `UConstRange` (unsigned constant range), `SConstRange` (signed constant range).
- If asked to handle multiple domains or multiple ops, split that into separate tasks and run this playbook once per `(domain, op)` pair.

## Task Inputs and Domain Mapping

Choose exactly one row for a task.

- `<DOMAIN>`: one of `KnownBits`, `UConstRange`, `SConstRange`.
- `<OP>`: concrete op filename stem in `mlir/Operations` (case-sensitive), e.g. `Shl`.
- `<op>`: lowercase stem used in transfer symbols and test function names, e.g. `shl`.

| Domain | File | Symbol | Encoding |
|---|---|---|---|
| `KnownBits` | `tests/data/kb_<OP>.mlir` | `kb_<op>` | index `0` = known-zero mask, index `1` = known-one mask |
| `UConstRange` | `tests/data/ucr_<OP>.mlir` | `ucr_<op>` | index `0` = lower bound, index `1` = upper bound |
| `SConstRange` | `tests/data/scr_<OP>.mlir` | `scr_<op>` | index `0` = lower bound, index `1` = upper bound |

## Key Clarifications (Required)

- The target for each transfer function is `100%` exact precision at `--exact-bw 7`. This is an optimization target, not a soundness exception: if `100%` is not achievable, keep the transfer sound and report the best precision reached.
- In real-world use cases, transfers run at high bitwidths (often 32 or 64). Avoid low-width-only tuning. Optional diagnostic checks at `--exact-bw 5,6,7,8` must not show a strong downward precision trend; `--norm-bw 64,10000,1000` must also be used to inspect high-bitwidth quality (lower is better).
- Ternary instructions (for example `fshl` and `fshr`) must not be evaluated with the same bitwidth settings as binary instructions. For ternary instructions, cap evaluation/soundness checks at bitwidth `5`.
- CI integration is out of scope.
- Primary tools are `verify` and `eval-final`; use `eval-point` for single abstract input-pair inspection.
- Reuse effective patterns from existing transfers. You may also suggest missing `transfer` dialect integer ops that would improve precision or efficiency.

## Execution Defaults (Single Source of Truth)

- `memlimit-cap`: `50G` (mandatory memory cap for all `verify` and `eval-final` invocations, via `python3 tools/memlimit.py`).
- `verify-final-flags`: `--bw 1-64 --timeout 120`.
- `verify-intermediate-flags`: keep `--bw 1-64` and lower `--timeout` only.
- `verify-bw-format` (mandatory): every `verify` command must use an explicit inclusive range that starts at `1` (for example `--bw 1-64` or `--bw 1-32`), never a single max-width form like `--bw 64`.
- `eval-final-flags`: `--exact-bw 7 --norm-bw 64,10000,1000`.
- `eval-intermediate-flags` (optional): `--exact-bw 6 --norm-bw 64,10000,1000`.
- `eval-final` outputs are not comparable across different `--exact-bw` values; only compare runs that use the same `--exact-bw`.
- Ternary-op override: for ternary instructions such as `fshl`/`fshr`, use `--bw 1-5` for `verify` and `--exact-bw 5` for `eval-final`/`eval-intermediate` (keep other flags unchanged).

## Tool Bug Policy (Required)

- If you hit a bug in any tool in this repository (for example `verify`, `eval-final`, `sxf`, lowering, or parsing), stop normal transfer-function work immediately.
- Report the bug clearly to the user first (minimal reproducer command, observed behavior, traceback/signature, and any relevant output paths/log files).
- Do not attempt a workaround by default.
- Mining logs or artifacts from the failed run is allowed, but only after the bug has been reported to the user.
- Only proceed with a workaround if the user explicitly asks for one after the bug report.
- If a workaround is requested, keep it scoped and temporary, and clearly label which results were obtained under workaround conditions.

## Shared Requirements

1. Match the transfer function arity to the concrete op in `mlir/Operations/<OP>.mlir`.
   - If `concrete_op` takes `N` integer inputs, the transfer must take `N` abstract value inputs and return one abstract value.
   - Keep the per-argument abstract type as `!transfer.abs_value<[!transfer.integer, !transfer.integer]>`.
   - Typical shapes:

```mlir
(!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
(!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
(!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
(!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
```

2. Transfer must be sound and as precise as possible.
3. Keep code bitwidth-agnostic.
4. Use timeout/bitwidth settings from Execution Defaults, including the mandatory `python3 tools/memlimit.py 50G -- ...` cap wrapper for `verify` and `eval-final`.
5. Keep changes minimal and repo-consistent.
6. Reuse existing transfer primitives whenever possible.
7. After each completed `(domain, op)` task, update `SYNTH_STATUS.md` for that exact row:
   - Set `Transfer File` to the concrete file path if added, otherwise keep missing status.
   - Record exact precision from the final `eval-final` run (Execution Defaults) in `Exact Precision`.
   - Record the highest proved-sound width from the final `verify` run (Execution Defaults) in `Highest Sound BW`.
   - Record the MLIR instruction count for the transfer function.
   - Update `Notes` with `sound through bw 64`, `stopped at bw <N> (timeout|unsound)`, or a command/tool error note.

## Construction Strategy (Recommended)

- Prefer composing the final transfer as the meet of several simpler transfer functions, each capturing one sound insight.
- Keep each candidate independently sound; the meet of sound candidates is also sound.
- Typical candidates include:
  - exact special cases (`lhs == 0`, `rhs == 0`, both operands constant),
  - validity/feasibility filters (e.g., whether the op constraints allow any concrete pair in-range),
  - monotonic endpoint bounds valid under explicit guards (sign-partitioned or no-overflow conditions).
- When encoding a meet in-range domains, use domain-consistent intersection logic (e.g., lower via `smax`/`umax`, upper via `smin`/`umin` as appropriate).

## Optional Idea Mining with `sxf` (5-minute Budget)

- If progress stalls, use `sxf` to generate ideas, not final code.
- Cap runtime to about 5 minutes:

```bash
timeout 300 sxf mlir/Operations/<OP>.mlir \
  -o /tmp/<DOMAIN>_<OP>_ideas \
  -d <DOMAIN> \
  --num-iters 1 \
  --num-steps 600 \
  --num-mcmc 80 \
  --program-length 40 \
  --condition-length 12 \
  --num-abd-procs 0 \
  --num-unsound-candidates 0 \
  --vbw 1-16 \
  --random-seed <seed>
```

- Quick usage notes:
  - If `timeout` is unavailable, use `gtimeout` with the same arguments.
  - Run 2-3 seeds and compare recurring patterns.
  - Keep `--num-iters 1`; use moderate `--num-steps`/`--num-mcmc` (for example `400-1200` and `60-120`).
  - Inspect `/tmp/<DOMAIN>_<OP>_ideas/info.log` and `debug.log` for reusable guards and partial high-precision candidates.
  - Treat mined snippets as hypotheses, then simplify and re-check with `verify`. If failure indicates a tool bug, apply Tool Bug Policy first.

## SSA IR Discipline (Important)

- This MLIR parser uses strict SSA form: each `%name = ...` must be an operation result.
- Do not write alias assignments like `%x = %y : !transfer.integer`.
- If you need another reference, reuse the original SSA value directly.
- After drafting a transfer file, run a quick `verify` with `verify-intermediate-flags` to catch parser/syntax issues, then run the final check with `verify-final-flags`.

## Domain-Specific Primitive Guidance

- `KnownBits`: prefer `transfer.and`, `transfer.or`, `transfer.xor`, `transfer.add`, `transfer.sub`, `transfer.shl`, `transfer.lshr`, `transfer.constant`, `transfer.get_all_ones`.
- `UConstRange` and `SConstRange`: same as above, plus `transfer.cmp`, `transfer.select`, and overflow predicates such as `transfer.uadd_overflow`, `transfer.sadd_overflow`, and `transfer.ssub_overflow` when useful.

## Command Templates

Run only the commands for the row selected in Task Inputs and Domain Mapping.
Let `<xfer-file>` be that row's file path. Use flag bundles from Execution Defaults.

```bash
( python3 tools/memlimit.py 50G -- verify --xfer-file <xfer-file> --domain <DOMAIN> --op mlir/Operations/<OP>.mlir <verify-final-flags> )
( python3 tools/memlimit.py 50G -- eval-final <xfer-file> --domain <DOMAIN> --op mlir/Operations/<OP>.mlir <eval-final-flags> )
# Optional intermediate variants:
# ( python3 tools/memlimit.py 50G -- verify ... <verify-intermediate-flags> )
# ( python3 tools/memlimit.py 50G -- eval-final ... <eval-intermediate-flags> )
```

## Testing Guidance

- Use `verify` as the soundness oracle.
- `verify` checks bitwidths from `1` up to the requested max width, and stops early on the first `timeout`; therefore the CLI form must be an explicit range beginning at `1` (for example `--bw 1-64`), never `--bw 64`.
- Use `eval-final` as the precision/quality metric. This command might be slow, but you must let it finish. Don't time this one out.
- Follow Execution Defaults for final reporting vs intermediate checks.

## Optional Test File Updates (Only If Asked)

| Domain | Verif test | JIT test |
|---|---|---|
| `KnownBits` | `tests/test_verif.py`: `test_verif_kb_<op>()` | `tests/test_jit.py`: `test_jit_with_kb_<op>()` |
| `UConstRange` | `tests/test_verif.py`: `test_verif_ucr_<op>()` | `tests/test_jit.py`: `test_jit_with_ucr_<op>()` |
| `SConstRange` | `tests/test_verif.py`: `test_verif_scr_<op>()` (if present/needed) | `tests/test_jit.py`: `test_jit_with_scr_<op>()` (if present/needed) |

## Required Return Format

1. Files changed.
2. Soundness results per tested bitwidth (`sound` / `unsound` / `timeout` plus runtime).
3. `eval-final` table values from the final run (Execution Defaults).
4. Precision and soundness caveats, clearly separating `timeout/unresolved` from `unsound`.

# Transfer Function Synthesis Status

## KnownBits

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | `tests/data/kb_Abds.mlir` | 90.87972345210684 | 26 | 415 | stopped at bw 27 (timeout) |
| `Abdu` | `tests/data/kb_Abdu.mlir` | 91.937602 | 64 | 189 | sound through bw 64 |
| `Add` | `tests/data/kb_Add.mlir` | 100.0 | 64 | 37 | sound through bw 64 |
| `AddNsw` | `tests/data/kb_AddNsw.mlir` | 95.392653 | 64 | 79 | sound through bw 64 |
| `AddNswNuw` | `tests/data/kb_AddNswNuw.mlir` | 93.384757 | 64 | 182 | sound through bw 64 |
| `AddNuw` | `tests/data/kb_AddNuw.mlir` | 100.0 | 64 | 56 | sound through bw 64 |
| `And` | `tests/data/kb_And.mlir` | 100.0 | 64 | 8 | sound through bw 64 |
| `Ashr` | `tests/data/kb_Ashr.mlir` | 99.268404 | 64 | 132 | sound through bw 64 |
| `AshrExact` | `tests/data/kb_AshrExact.mlir` | 95.515421 | 64 | 134 | sound through bw 64 |
| `AvgCeilS` | `tests/data/kb_AvgCeilS.mlir` | 98.32430442262954 | 28 | 1956 | stopped at bw 29 (timeout) |
| `AvgCeilU` | `tests/data/kb_AvgCeilU.mlir` | 98.23139142235712 | 28 | 1945 | stopped at bw 29 (timeout) |
| `AvgFloorS` | `tests/data/kb_AvgFloorS.mlir` | 98.90202089957096 | 39 | 1923 | stopped at bw 40 (timeout) |
| `AvgFloorU` | `tests/data/kb_AvgFloorU.mlir` | 98.5801287861159 | 40 | 1912 | stopped at bw 41 (timeout) |
| `CountLOne` | `tests/data/kb_CountLOne.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `CountLZero` | `tests/data/kb_CountLZero.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `CountROne` | `tests/data/kb_CountROne.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `CountRZero` | `tests/data/kb_CountRZero.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `Fshl` | `tests/data/kb_Fshl.mlir` | 93.51092 | 5 | 76 | sound through bw 5 (ternary cap; exact run used `--exact-bw 5`) |
| `Fshr` | `tests/data/kb_Fshr.mlir` | 93.51092 | 5 | 76 | sound through bw 5 (ternary cap; exact run used `--exact-bw 5`) |
| `Lshr` | `tests/data/kb_Lshr.mlir` | 100.0 | 64 | 247 | sound through bw 64 |
| `LshrExact` | `tests/data/kb_LshrExact.mlir` | 100.0 | 64 | 278 | sound through bw 64 |
| `Mods` | `tests/data/kb_Mods.mlir` | 66.528614 | 31 | 75 | stopped at bw 32 (timeout) |
| `Modu` | `tests/data/kb_Modu.mlir` | 98.803944 | 6 | 1698 | stopped at bw 7 (timeout) |
| `Mul` | `tests/data/kb_Mul.mlir` | 95.3205007182777 | 7 | 1872 | stopped at bw 8 (timeout) |
| `MulNsw` | `tests/data/kb_MulNsw.mlir` | 94.488507 | 8 | 2433 | stopped at bw 9 (timeout) |
| `MulNswNuw` | `tests/data/kb_MulNswNuw.mlir` | 92.084644 | 9 | 2945 | stopped at bw 10 (timeout) |
| `MulNuw` | `tests/data/kb_MulNuw.mlir` | 93.340977 | 9 | 2413 | stopped at bw 10 (timeout) |
| `Nop` | `tests/data/kb_Nop.mlir` | 100.0 | 64 | 1 | sound through bw 64 |
| `Or` | `tests/data/kb_Or.mlir` | 100.0 | 64 | 8 | sound through bw 64 |
| `PopCount` | `tests/data/kb_PopCount.mlir` | 100.0 | 64 | 21 | sound through bw 64 |
| `Rotl` | `tests/data/kb_Rotl.mlir` | 94.361327 | 32 | 54 | stopped at bw 33 (timeout) |
| `Rotr` | `tests/data/kb_Rotr.mlir` | 94.361327 | 34 | 54 | stopped at bw 35 (timeout) |
| `SaddSat` | `tests/data/kb_SaddSat.mlir` | 97.72124803652292 | 18 | 2898 | stopped at bw 19 (timeout) |
| `Sdiv` | `tests/data/kb_Sdiv.mlir` | 98.7710562205191 | 7 | 3665 | stopped at bw 8 (timeout) |
| `SdivExact` | `tests/data/kb_SdivExact.mlir` | 94.43228672399925 | 6 | 4433 | stopped at bw 7 (timeout) |
| `Shl` | `tests/data/kb_Shl.mlir` | 91.653511 | 64 | 268 | sound through bw 64 |
| `ShlNsw` | `tests/data/kb_ShlNsw.mlir` | 88.501201 | 64 | 442 | sound through bw 64 |
| `ShlNswNuw` | `tests/data/kb_ShlNswNuw.mlir` | 89.52014951382708 | 64 | 489 | sound through bw 64 |
| `ShlNuw` | `tests/data/kb_ShlNuw.mlir` | 89.526045 | 64 | 489 | sound through bw 64 |
| `Smax` | `tests/data/kb_Smax.mlir` | 98.44590253459722 | 64 | 1123 | sound through bw 64 |
| `Smin` | `tests/data/kb_Smin.mlir` | 98.44590253459722 | 64 | 1123 | sound through bw 64 |
| `SmulSat` | `tests/data/kb_SmulSat.mlir` | 98.48813571653925 | 8 | 3410 | stopped at bw 9 (timeout) |
| `Square` | `tests/data/kb_Square.mlir` | 98.8111568358482 | 14 | 127 | stopped at bw 15 (timeout) |
| `SshlSat` | `tests/data/kb_SshlSat.mlir` | 93.669288 | 64 | 456 | sound through bw 64 |
| `SsubSat` | `tests/data/kb_SsubSat.mlir` | 97.252836 | 46 | 696 | stopped at bw 47 (timeout); used equivalent local op workaround for verifier lowering bug on `transfer.is_negative` |
| `Sub` | `tests/data/kb_Sub.mlir` | 97.2441803407047 | 42 | 1117 | stopped at bw 43 (timeout) |
| `SubNsw` | `tests/data/kb_SubNsw.mlir` | 96.38095082782263 | 14 | 2397 | stopped at bw 15 (timeout) |
| `SubNswNuw` | `tests/data/kb_SubNswNuw.mlir` | 74.28919150427276 | 64 | 343 | sound through bw 64 |
| `SubNuw` | `tests/data/kb_SubNuw.mlir` | 99.52222144864413 | 64 | 343 | sound through bw 64 |
| `UaddSat` | `tests/data/kb_UaddSat.mlir` | 100.0 | 64 | 347 | sound through bw 64 |
| `Udiv` | `tests/data/kb_Udiv.mlir` | 92.39903081119698 | 63 | 85 | stopped at bw 64 (timeout) |
| `UdivExact` | `tests/data/kb_UdivExact.mlir` | 95.945949 | 5 | 49453 | stopped at bw 6 (timeout) |
| `Umax` | `tests/data/kb_Umax.mlir` | 100.0 | 64 | 81 | sound through bw 64 |
| `Umin` | `tests/data/kb_Umin.mlir` | 100.0 | 64 | 81 | sound through bw 64 |
| `UmulSat` | `tests/data/kb_UmulSat.mlir` | 89.429055 | 13 | 365 | stopped at bw 14 (timeout) |
| `UshlSat` | `tests/data/kb_UshlSat.mlir` | 94.948702 | 64 | 265 | sound through bw 64 |
| `UsubSat` | `tests/data/kb_UsubSat.mlir` | 99.746183 | 64 | 317 | sound through bw 64 |
| `Xor` | `tests/data/kb_Xor.mlir` | 100.0 | 64 | 12 | sound through bw 64 |

## UConstRange

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
| `Add` | `tests/data/ucr_Add.mlir` | 100.0 | 64 | 17 | sound through bw 64 |
| `AddNsw` | — | missing | — | — | transfer file not present |
| `AddNswNuw` | `tests/data/ucr_AddNswNuw.mlir` | 100.0 | 64 | 54 | sound through bw 64 |
| `AddNuw` | `tests/data/ucr_AddNuw.mlir` | 100.0 | 64 | 17 | sound through bw 64 |
| `And` | `tests/data/ucr_And.mlir` | 75.482397 | 0 | 372 | verify command error |
| `Ashr` | — | missing | — | — | transfer file not present |
| `AshrExact` | — | missing | — | — | transfer file not present |
| `AvgCeilS` | `tests/data/ucr_AvgCeilS.mlir` | 100.0 | 51 | 83 | stopped at bw 52 (timeout) |
| `AvgCeilU` | — | missing | — | — | transfer file not present |
| `AvgFloorS` | — | missing | — | — | transfer file not present |
| `AvgFloorU` | — | missing | — | — | transfer file not present |
| `CountLOne` | — | missing | — | — | transfer file not present |
| `CountLZero` | — | missing | — | — | transfer file not present |
| `CountROne` | — | missing | — | — | transfer file not present |
| `CountRZero` | — | missing | — | — | transfer file not present |
| `Fshl` | — | missing | — | — | transfer file not present |
| `Fshr` | — | missing | — | — | transfer file not present |
| `Lshr` | — | missing | — | — | transfer file not present |
| `LshrExact` | — | missing | — | — | transfer file not present |
| `Mods` | — | missing | — | — | transfer file not present |
| `Modu` | — | missing | — | — | transfer file not present |
| `Mul` | — | missing | — | — | transfer file not present |
| `MulNsw` | — | missing | — | — | transfer file not present |
| `MulNswNuw` | — | missing | — | — | transfer file not present |
| `MulNuw` | — | missing | — | — | transfer file not present |
| `Nop` | — | missing | — | — | transfer file not present |
| `Or` | — | missing | — | — | transfer file not present |
| `PopCount` | — | missing | — | — | transfer file not present |
| `Rotl` | — | missing | — | — | transfer file not present |
| `Rotr` | — | missing | — | — | transfer file not present |
| `SaddSat` | — | missing | — | — | transfer file not present |
| `Sdiv` | — | missing | — | — | transfer file not present |
| `SdivExact` | — | missing | — | — | transfer file not present |
| `Shl` | `tests/data/ucr_Shl.mlir` | 99.999727 | 64 | 129 | sound through bw 64 |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
| `SshlSat` | — | missing | — | — | transfer file not present |
| `SsubSat` | — | missing | — | — | transfer file not present |
| `Sub` | `tests/data/ucr_Sub.mlir` | 100.0 | 64 | 15 | sound through bw 64 |
| `SubNsw` | — | missing | — | — | transfer file not present |
| `SubNswNuw` | `tests/data/ucr_SubNswNuw.mlir` | 100.0 | 64 | 60 | sound through bw 64 |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
| `UdivExact` | `tests/data/ucr_UdivExact.mlir` | 83.04657 | 16 | 35 | stopped at bw 17 (timeout) |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
| `Xor` | `tests/data/ucr_Xor.mlir` | 51.9463 | 64 | 42 | sound through bw 64 |

## SConstRange

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
| `Add` | — | missing | — | — | transfer file not present |
| `AddNsw` | — | missing | — | — | transfer file not present |
| `AddNswNuw` | `tests/data/scr_AddNswNuw.mlir` | 100.0 | 64 | 57 | sound through bw 64 |
| `AddNuw` | — | missing | — | — | transfer file not present |
| `And` | `tests/data/scr_And.mlir` | 64.144194 | 0 | 366 | verify command error |
| `Ashr` | — | missing | — | — | transfer file not present |
| `AshrExact` | — | missing | — | — | transfer file not present |
| `AvgCeilS` | `tests/data/scr_AvgCeilS.mlir` | 100.0 | 64 | 15 | sound through bw 64 |
| `AvgCeilU` | — | missing | — | — | transfer file not present |
| `AvgFloorS` | — | missing | — | — | transfer file not present |
| `AvgFloorU` | — | missing | — | — | transfer file not present |
| `CountLOne` | — | missing | — | — | transfer file not present |
| `CountLZero` | — | missing | — | — | transfer file not present |
| `CountROne` | — | missing | — | — | transfer file not present |
| `CountRZero` | — | missing | — | — | transfer file not present |
| `Fshl` | — | missing | — | — | transfer file not present |
| `Fshr` | — | missing | — | — | transfer file not present |
| `Lshr` | — | missing | — | — | transfer file not present |
| `LshrExact` | — | missing | — | — | transfer file not present |
| `Mods` | — | missing | — | — | transfer file not present |
| `Modu` | — | missing | — | — | transfer file not present |
| `Mul` | — | missing | — | — | transfer file not present |
| `MulNsw` | — | missing | — | — | transfer file not present |
| `MulNswNuw` | — | missing | — | — | transfer file not present |
| `MulNuw` | — | missing | — | — | transfer file not present |
| `Nop` | — | missing | — | — | transfer file not present |
| `Or` | — | missing | — | — | transfer file not present |
| `PopCount` | — | missing | — | — | transfer file not present |
| `Rotl` | — | missing | — | — | transfer file not present |
| `Rotr` | — | missing | — | — | transfer file not present |
| `SaddSat` | — | missing | — | — | transfer file not present |
| `Sdiv` | — | missing | — | — | transfer file not present |
| `SdivExact` | `tests/data/scr_SdivExact.mlir` | 24.318789 | 13 | 162 | stopped at bw 14 (timeout) |
| `Shl` | `tests/data/scr_Shl.mlir` | 46.355066 | 64 | 85 | sound through bw 64 |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
| `SshlSat` | — | missing | — | — | transfer file not present |
| `SsubSat` | — | missing | — | — | transfer file not present |
| `Sub` | `tests/data/scr_Sub.mlir` | 100.0 | 64 | 17 | sound through bw 64 |
| `SubNsw` | — | missing | — | — | transfer file not present |
| `SubNswNuw` | `tests/data/scr_SubNswNuw.mlir` | 100.0 | 64 | 67 | sound through bw 64 |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
| `UdivExact` | — | missing | — | — | transfer file not present |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
| `Xor` | `tests/data/scr_Xor.mlir` | 54.887049 | 64 | 54 | sound through bw 64 |
