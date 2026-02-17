# Transfer Function Playbook (`<DOMAIN>`, `<OP>`)

Implement or improve one transfer function in this repo.

## Scope Per Task (Hard Rule)

- Work on exactly one abstract domain and one operation at a time.
- Allowed domains: `KnownBits`, `UConstRange` (unsigned constant range), `SConstRange` (signed constant range).
- If asked to handle multiple domains or multiple ops, split that into separate tasks and run this playbook once per `(domain, op)` pair.

## Key Clarifications

- The target for each transfer function is `100%` exact precision at `--exact-bw 7`. This is an optimization target, not a soundness exception: if `100%` is not achievable, keep the transfer sound and report the best precision reached.
- In real-world use cases, the transfer functions you create will often be used at high bitwidths such as 32 or 64. Avoid specializing solutions primarily for low widths. Focus on high-bitwidth behavior. Specifically, ensure the exhaustive checks `--exact-bw 5`, `--exact-bw 6`, `--exact-bw 7`, and `--exact-bw 8` do not show a significant downward trend in precision. You can also directly examine high-bitwidth precision with `--norm-bw 64,10000,1000`; for these norms, lower values are better.
- CI integration is not required for this task.
- Primary tools are `verify-upto` and `eval-final`.
- If you need to inspect one specific abstract input pair, use `eval-point` for a single-point transfer evaluation.
- You may optionally suggest concrete missing `transfer` dialect integer ops that would enable better precision or efficiency.
- It is always fine, and encouraged, to reuse tricks and techniques from existing transfer functions when creating new ones.

## Placeholder Conventions

- `<DOMAIN>`: one of `KnownBits`, `UConstRange`, `SConstRange`.
- `<OP>`: concrete op filename stem in `mlir/Operations` (case-sensitive), e.g. `Shl`.
- `<op>`: lowercase stem used in transfer filenames under `tests/data`, e.g. `shl`.

## Execution Defaults (Single Source of Truth)

- `verify-upto` final reporting settings: `--bw 64 --timeout 120`.
- For faster intermediate `verify-upto` feedback, lower `--timeout` only (never lower `--bw`).
- `eval-final` final reporting settings: `--exact-bw 7 --norm-bw 64,10000,1000`.
- Optional faster intermediate `eval-final`: `--exact-bw 6 --norm-bw 64,10000,1000`.
- `eval-final` outputs are not comparable across different `--exact-bw` values; only compare runs that use the same `--exact-bw`.

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
4. Keep solver timeout at or below `120` seconds (see Execution Defaults for intermediate vs final settings).
5. Keep changes minimal and repo-consistent.
6. Reuse existing transfer primitives whenever possible.
7. After each completed `(domain, op)` task, update `SYNTH_STATUS.md` for that exact row:
   - Set `Transfer File` to the concrete file path if added, otherwise keep missing status.
   - Record exact precision from `eval-final ... --exact-bw 7 --norm-bw 64,10000,1000` in the `Exact Precision` column.
   - Record the highest proved-sound width from `verify-upto --bw 64 --timeout 120` in `Highest Sound BW`.
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

- To get the most from this command:
  - If `timeout` is unavailable on your system, use `gtimeout` with the same arguments.
  - Run 2-3 different seeds and compare recurring patterns.
  - Keep `--num-iters 1`; in this workflow you want candidate ideas quickly, not a full synthesis run.
  - Use moderate `--num-steps`/`--num-mcmc` (for example, `400-1200` and `60-120`) to trade breadth vs. depth.
  - Inspect `/tmp/<DOMAIN>_<OP>_ideas/info.log` and `/tmp/<DOMAIN>_<OP>_ideas/debug.log` for high-precision partial candidates and reusable guard patterns.
  - Treat mined snippets as hypotheses: manually simplify, convert to meet-style sub-transfers, then re-check with `verify-upto`.
  - If `sxf` fails or times out, partial logs can still be useful for extracting ideas.
  - If the failure appears to be a tool bug, follow the Tool Bug Policy before mining failed-run logs.

## SSA IR Discipline (Important)

- This MLIR parser uses strict SSA form: each `%name = ...` must be an operation result.
- Do not write alias assignments like `%x = %y : !transfer.integer`.
- If you need another reference, reuse the original SSA value directly.
- After drafting a transfer file, run a quick timeout-limited `verify-upto` first (still with `--bw 64`) to catch parser/syntax issues, then run your final `--timeout 120` check.

## Domain-Specific Mapping

Choose one row only for a given task.

| Domain | File | Symbol | Encoding |
|---|---|---|---|
| `KnownBits` | `tests/data/kb_<op>.mlir` | `kb_<op>` | index `0` = known-zero mask, index `1` = known-one mask |
| `UConstRange` | `tests/data/ucr_<op>.mlir` | `ucr_<op>` | index `0` = lower bound, index `1` = upper bound |
| `SConstRange` | `tests/data/scr_<op>.mlir` | `scr_<op>` | index `0` = lower bound, index `1` = upper bound |

## Domain-Specific Primitive Guidance

- `KnownBits`: prefer `transfer.and`, `transfer.or`, `transfer.xor`, `transfer.add`, `transfer.sub`, `transfer.shl`, `transfer.lshr`, `transfer.constant`, `transfer.get_all_ones`.
- `UConstRange` and `SConstRange`: same as above, plus `transfer.cmp`, `transfer.select`, and overflow predicates such as `transfer.uadd_overflow`, `transfer.sadd_overflow`, and `transfer.ssub_overflow` when useful.

## Command Templates

Run only the commands for the domain row you chose in Domain-Specific Mapping.
Let `<xfer-file>` be the file path from that row. Optional `sxf` idea-mining above is still allowed.

```bash
verify-upto --xfer-file <xfer-file> --bw 64 --timeout 120 --domain <DOMAIN> --op mlir/Operations/<OP>.mlir
eval-final <xfer-file> --domain <DOMAIN> --op mlir/Operations/<OP>.mlir --exact-bw 7 --norm-bw 64,10000,1000
# Optional faster intermediate feedback (not comparable to --exact-bw 7 runs):
# eval-final <xfer-file> --domain <DOMAIN> --op mlir/Operations/<OP>.mlir --exact-bw 6 --norm-bw 64,10000,1000
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
3. `eval-final` table values (run with `--exact-bw 7 --norm-bw 64,10000,1000`).
4. Precision and soundness caveats, clearly separating `timeout/unresolved` from `unsound`.
