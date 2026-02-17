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
- `<op>`: lowercase stem used in transfer filenames under `tests/data`, e.g. `shl`.

| Domain | File | Symbol | Encoding |
|---|---|---|---|
| `KnownBits` | `tests/data/kb_<op>.mlir` | `kb_<op>` | index `0` = known-zero mask, index `1` = known-one mask |
| `UConstRange` | `tests/data/ucr_<op>.mlir` | `ucr_<op>` | index `0` = lower bound, index `1` = upper bound |
| `SConstRange` | `tests/data/scr_<op>.mlir` | `scr_<op>` | index `0` = lower bound, index `1` = upper bound |

## Key Clarifications (Required)

- The target for each transfer function is `100%` exact precision at `--exact-bw 7`. This is an optimization target, not a soundness exception: if `100%` is not achievable, keep the transfer sound and report the best precision reached.
- In real-world use cases, transfers run at high bitwidths (often 32 or 64). Avoid low-width-only tuning. Optional diagnostic checks at `--exact-bw 5,6,7,8` must not show a strong downward precision trend; `--norm-bw 64,10000,1000` must also be used to inspect high-bitwidth quality (lower is better).
- Ternary instructions (for example `fshl` and `fshr`) must not be evaluated with the same bitwidth settings as binary instructions. For ternary instructions, cap evaluation/soundness checks at bitwidth `5`.
- CI integration is out of scope.
- Primary tools are `verify-upto` and `eval-final`; use `eval-point` for single abstract input-pair inspection.
- Reuse effective patterns from existing transfers. You may also suggest missing `transfer` dialect integer ops that would improve precision or efficiency.

## Execution Defaults (Single Source of Truth)

- `vmem-ulimit-kib`: `52428800` (mandatory 50 GiB virtual-memory cap for all `verify-upto` and `eval-final` invocations).
- `verify-final-flags`: `--bw 64 --timeout 120`.
- `verify-intermediate-flags`: keep `--bw 64` and lower `--timeout` only.
- `eval-final-flags`: `--exact-bw 7 --norm-bw 64,10000,1000`.
- `eval-intermediate-flags` (optional): `--exact-bw 6 --norm-bw 64,10000,1000`.
- `eval-final` outputs are not comparable across different `--exact-bw` values; only compare runs that use the same `--exact-bw`.
- Ternary-op override: for ternary instructions such as `fshl`/`fshr`, use `--bw 5` for `verify-upto` and `--exact-bw 5` for `eval-final`/`eval-intermediate` (keep other flags unchanged).

## Tool Bug Policy (Required)

- If you hit a bug in any tool in this repository (for example `verify-upto`, `eval-final`, `sxf`, lowering, or parsing), stop normal transfer-function work immediately.
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
```

2. Transfer must be sound and as precise as possible.
3. Keep code bitwidth-agnostic.
4. Use timeout/bitwidth settings from Execution Defaults, including the mandatory `ulimit -v 52428800` cap for `verify-upto` and `eval-final`.
5. Keep changes minimal and repo-consistent.
6. Reuse existing transfer primitives whenever possible.
7. After each completed `(domain, op)` task, update `SYNTH_STATUS.md` for that exact row:
   - Set `Transfer File` to the concrete file path if added, otherwise keep missing status.
   - Record exact precision from the final `eval-final` run (Execution Defaults) in `Exact Precision`.
   - Record the highest proved-sound width from the final `verify-upto` run (Execution Defaults) in `Highest Sound BW`.
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
  - Treat mined snippets as hypotheses, then simplify and re-check with `verify-upto`. If failure indicates a tool bug, apply Tool Bug Policy first.

## SSA IR Discipline (Important)

- This MLIR parser uses strict SSA form: each `%name = ...` must be an operation result.
- Do not write alias assignments like `%x = %y : !transfer.integer`.
- If you need another reference, reuse the original SSA value directly.
- After drafting a transfer file, run a quick `verify-upto` with `verify-intermediate-flags` to catch parser/syntax issues, then run the final check with `verify-final-flags`.

## Domain-Specific Primitive Guidance

- `KnownBits`: prefer `transfer.and`, `transfer.or`, `transfer.xor`, `transfer.add`, `transfer.sub`, `transfer.shl`, `transfer.lshr`, `transfer.constant`, `transfer.get_all_ones`.
- `UConstRange` and `SConstRange`: same as above, plus `transfer.cmp`, `transfer.select`, and overflow predicates such as `transfer.uadd_overflow`, `transfer.sadd_overflow`, and `transfer.ssub_overflow` when useful.

## Command Templates

Run only the commands for the row selected in Task Inputs and Domain Mapping.
Let `<xfer-file>` be that row's file path. Use flag bundles from Execution Defaults.

```bash
( ulimit -v 52428800; verify-upto --xfer-file <xfer-file> --domain <DOMAIN> --op mlir/Operations/<OP>.mlir <verify-final-flags> )
( ulimit -v 52428800; eval-final <xfer-file> --domain <DOMAIN> --op mlir/Operations/<OP>.mlir <eval-final-flags> )
# Optional intermediate variants:
# ( ulimit -v 52428800; verify-upto ... <verify-intermediate-flags> )
# ( ulimit -v 52428800; eval-final ... <eval-intermediate-flags> )
```

## Testing Guidance

- Use `verify-upto` as the soundness oracle.
- `verify-upto` checks bitwidths from `1` up to the requested max width, and stops early on the first `timeout`.
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
