# Manual MLIR Optimization Playbook (Transfer Dialect)

This guide describes a repeatable workflow for manually porting LLVM `opt` improvements back into transfer-dialect MLIR while preserving semantics and precision.

Use this when:
- You have a transformer MLIR file.
- You can lower it with `lower-to-llvm`.
- You want to manually realize LLVM optimization ideas in MLIR.

## 1. Preconditions

- Run from repo root.
- Confirm tools are installed and callable:
  - `lower-to-llvm`
  - `opt`
  - `verify`
  - `eval-final`
- Choose a representative bitwidth for LLVM-side analysis (commonly `8` for quick iteration).

Important:
- `lower-to-llvm` requires `-bw`.
- `opt` may warn about unknown target triple/data layout. This warning can be ignored for this workflow.

## 2. File Setup and Baseline Capture

Assume target file is `tests/data/FOO.mlir` and concrete op is `mlir/Operations/Op.mlir`.

Before running validation, confirm the concrete op file is correct.
- Example: `kb_addnsw.mlir` pairs with `mlir/Operations/AddNsw.mlir`, not a generic placeholder path.
- Quick check:

```bash
ls mlir/Operations
```

1. Save a baseline copy.
2. Run baseline soundness.
3. Run baseline precision with fixed seed.
4. Record instruction counts.

Commands:

```bash
cp tests/data/FOO.mlir outputs/FOO.baseline.mlir

verify --bw 4-64 -d KnownBits \
  --op mlir/Operations/Op.mlir \
  --xfer-file tests/data/FOO.mlir

eval-final tests/data/FOO.mlir -d KnownBits \
  --op mlir/Operations/Op.mlir \
  --exact-bw 8,5000 --norm-bw 64,5000,5000 \
  --random-seed 12345

awk '/= "transfer\./{n++} END{print n}' tests/data/FOO.mlir
awk '/= "transfer\./{n++} /"func.return"\(/{n++} END{print n}' tests/data/FOO.mlir
```

## 3. Produce LLVM Before/After

Generate pre-opt LLVM:

```bash
lower-to-llvm -bw 8 -i tests/data/FOO.mlir -o outputs/FOO.8.pre.ll
```

Run one or more LLVM pipelines:

```bash
opt -O2 -S outputs/FOO.8.pre.ll -o outputs/FOO.8.O2.ll

opt -S -passes='sccp,gvn,adce,reassociate,dse,instcombine,sccp,gvn,adce,reassociate,dse,instcombine,sccp,gvn,adce,reassociate,dse,instcombine' \
  outputs/FOO.8.pre.ll -o outputs/FOO.8.custom.ll
```

Diff:

```bash
diff -u outputs/FOO.8.pre.ll outputs/FOO.8.custom.ll | sed -n '1,260p'
```

## 4. How to Read LLVM Diffs

Classify changes into two buckets.

Portable to MLIR:
- Algebraic identities that are bitwidth-generic.
- Dead code elimination and common-subexpression elimination.
- Equivalent condition/value rewrites that map directly to transfer ops.
- Replace generic mask construction with domain-provided constants if available.

Do not port directly:
- LLVM-only canonical forms (`or disjoint`, range metadata, attributes).
- Vectorization/reduction constructs that have no transfer-dialect equivalent.
- Target/layout-specific transforms.
- Changes relying on LLVM undefined behavior subtleties not represented in transfer semantics.

## 5. Safe Rewrite Patterns (Proven Useful)

Pattern A: Remove duplicate computation (CSE)
- If the same transfer operation appears twice with identical operands/attrs, keep one definition and reuse it.

Pattern B: Boolean mask select to arithmetic bitmask
- Example shape:
  - `select(max_is_neg, signmask, 0)` -> `and(value_checked_by_max_is_neg, signmask)`
- Only apply when `max_is_neg` is exactly `(value < 0)` and mask semantics match.

Pattern C: Sign check simplification
- If a sign test is performed on a value whose sign bit is known to equal another operand’s sign bit, compare the simpler operand.
- Example:
  - `cmp(lhs_smax, 0, slt)` -> `cmp(lhs1, 0, slt)` when construction guarantees identical sign bit.

Pattern D: Use domain primitives instead of synthesized mask building
- Replace:
  - `signmask = shl(1, bw-1)`
  - `not_signmask = xor(signmask, all_ones)`
- With:
  - `smin = get_signed_min_value(...)` (sign bit mask)
  - `smax = get_signed_max_value(...)` (non-sign-bit mask)
- Then rewrite all uses.

Pattern E: Two’s complement identity
- For fixed-width modular arithmetic:
  - `~(~a + ~b) == a + b + 1`
- In transfer form, this can remove an inversion chain in carry logic.

Pattern F: Collapse paired bit-tests into one bitwise expression
- Example shape:
  - `cmp(and(a,1),1) && cmp(and(b,1),1)` plus `select(...,1,0)`
  - can become:
  - `t = and(a,b)`, `bit = and(t,1)`, `cmp(bit,1)`
- This removes duplicated `and/cmp/select` scaffolding while preserving bit intent.

Pattern G: Replace sign-mask equality checks with signed compare to zero
- Example shape:
  - `cmp(and(x, sign_mask), sign_mask, eq)` -> `cmp(x, 0, slt)`
- Apply only when `sign_mask` is exactly the sign bit mask for the operand width.

Pattern H: Collapse over-enumerated unknown-case partitions
- If a dynamic-case split enumerates many possibilities (e.g. 4-way feasibility trees), verify whether transfer semantics imply fewer feasible classes.
- Large wins often come from reducing N-way trees to 2-way trees plus gating.
- For semantics-sensitive ops, confirm lowering behavior in `synth_xfer/_util/lower.py` before rewriting around them.

## 6. Rewrite Discipline

When editing MLIR:
- Make one small logical rewrite at a time.
- Keep names readable and stable.
- Avoid broad refactors unrelated to optimization.
- Re-run `lower-to-llvm` after each rewrite batch and inspect diff against previous lowered LLVM.

## 7. Mandatory Validation After Every Batch

1. Soundness:

```bash
verify --bw 4-64 -d KnownBits \
  --op mlir/Operations/Op.mlir \
  --xfer-file tests/data/FOO.mlir
```

If full-range verify is too slow, run ranges in parallel (up to 10 workers):

```bash
printf '%s\n' 4-9 10-15 16-21 22-27 28-33 34-39 40-45 46-51 52-57 58-64 | \
  xargs -I{} -P 10 sh -c '
    verify --bw {} -d KnownBits \
      --op mlir/Operations/Op.mlir \
      --xfer-file tests/data/FOO.mlir > outputs/FOO.verify.{}.log
  '

rg -n "unsound|timeout" outputs/FOO.verify.*.log
```

Timeout handling rule:
- Treat `timeout` as unknown, not sound.
- If timeouts appear, rerun only timed-out ranges with a larger SMT timeout:

```bash
verify --bw 34-39 -d KnownBits \
  --op mlir/Operations/Op.mlir \
  --xfer-file tests/data/FOO.mlir \
  --timeout 120
```

2. Precision (fixed random seed):

```bash
eval-final tests/data/FOO.mlir -d KnownBits \
  --op mlir/Operations/Op.mlir \
  --exact-bw 8,5000 --norm-bw 64,5000,5000 \
  --random-seed 12345
```

3. Optional focused tests:

```bash
pytest -q tests/test_verif.py::test_verif_... tests/test_jit.py::test_jit_...
```

Reject any rewrite if:
- `verify` finds unsoundness at any bitwidth.
- `eval-final` precision changes unexpectedly.
- Tests regress.

## 8. Measure and Report Improvements

Recommended metrics:
- MLIR transfer op count.
- MLIR transfer op + return count.
- Lowered LLVM line count (pre-pass).
- Lowered LLVM line count after chosen pass pipeline.

Commands:

```bash
awk '/= "transfer\./{n++} END{print n}' outputs/FOO.baseline.mlir
awk '/= "transfer\./{n++} END{print n}' tests/data/FOO.mlir

wc -l outputs/FOO.8.pre.ll outputs/FOO.8.custom.ll
```

Suggested report template:

```text
File optimized: tests/data/FOO.mlir
Passes used for idea mining: <pipeline>

Applied rewrites:
1) <rewrite> at <file:line>
2) <rewrite> at <file:line>

Validation:
- verify --bw 4-64: all sound / sound+timeouts (list ranges)
- eval-final (seed 12345): unchanged / changed (details)
- focused tests: pass/fail

Size impact:
- MLIR transfer ops: A -> B (delta, percent)
- LLVM pre-pass lines: C -> D
- LLVM post-pass lines: E -> F
```

## 9. Practical Heuristics for “Awesome” Results

- Prefer rewrites that reduce MLIR ops directly, not just rename/canonicalize.
- Favor substitutions that eliminate dynamic mask-building logic.
- Reuse already-computed intermediates aggressively.
- Treat LLVM constants from `-bw 8` as hints only. Convert to bitwidth-generic MLIR forms before committing.
- Prioritize rewrites that remove case-explosion structure (multi-branch feasibility trees); these usually dominate wins.
- If post-pass LLVM line count is unchanged but pre-pass LLVM and MLIR op counts drop, the rewrite is still valuable.
- Iterate: apply small batch -> validate -> re-lower -> mine new opportunities.
- Stop when repeated pass mining yields only LLVM-specific canonicalization with no MLIR-op reduction opportunity.

## 10. Common Pitfalls

- Porting bitwidth-specific constants literally (`127`, `128`) into generic MLIR.
- Applying a rewrite based on value equivalence without proving predicate equivalence.
- Trusting only one check (`verify` or `eval-final`); always run both.
- Treating `verify` timeouts as success.
- Assuming transfer-op semantics from name alone (for some ops, lowering behavior is subtler than the name suggests; e.g. `transfer.neg` lowering is not arithmetic negation).
- Counting LLVM line reductions as success if MLIR op count and validation do not improve.
