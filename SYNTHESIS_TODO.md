# Synthesis TODO

Precision-improvement backlog for transfer functions in `KnownBits`, `UConstRange`, and `SConstRange` where `Synth Exact %` changed materially between:

- `eval-final ... --exact-bw 7 --norm-bw 64,10000,1000`
- `eval-final ... --exact-bw 7,2000 --norm-bw 64,10000,1000`

Current goal for each item:

- Improve precision.
- Reduce sensitivity to exact-sampling configuration.
- Re-check with both `--exact-bw 7` and `--exact-bw 7,2000`.

## Priority Queue (By `|delta_synth|`)

- [ ] `tests/data/kb_sdivexact.mlir` (`KnownBits` / `SdivExact`): `14.1119 -> 64.85` (`|delta| = 50.7381`)
- [ ] `tests/data/scr_shl.mlir` (`SConstRange` / `Shl`): `46.3551 -> 5.45` (`|delta| = 40.9051`)
- [ ] `tests/data/ucr_xor.mlir` (`UConstRange` / `Xor`): `51.9463 -> 78.25` (`|delta| = 26.3037`)
- [ ] `tests/data/scr_xor.mlir` (`SConstRange` / `Xor`): `54.8870 -> 79.3` (`|delta| = 24.4130`)
- [ ] `tests/data/kb_mul.mlir` (`KnownBits` / `Mul`): `57.0072 -> 75.25` (`|delta| = 18.2428`)
- [ ] `tests/data/ucr_and.mlir` (`UConstRange` / `And`): `75.4824 -> 90.45` (`|delta| = 14.9676`)
- [ ] `tests/data/kb_mods.mlir` (`KnownBits` / `Mods`): `66.5286 -> 81.3` (`|delta| = 14.7714`)
- [ ] `tests/data/kb_udivexact.mlir` (`KnownBits` / `UdivExact`): `95.8316 -> 81.85` (`|delta| = 13.9816`)
- [ ] `tests/data/scr_sdivexact.mlir` (`SConstRange` / `SdivExact`): `24.3188 -> 11.55` (`|delta| = 12.7688`)
- [ ] `tests/data/scr_and.mlir` (`SConstRange` / `And`): `64.1442 -> 75.9` (`|delta| = 11.7558`)
- [ ] `tests/data/ucr_udivexact.mlir` (`UConstRange` / `UdivExact`): `83.0466 -> 92.45` (`|delta| = 9.4034`)
- [ ] `tests/data/kb_sshlsat.mlir` (`KnownBits` / `SshlSat`): `93.6693 -> 87.85` (`|delta| = 5.8193`)
- [ ] `tests/data/kb_addnsw.mlir` (`KnownBits` / `AddNsw`): `95.3927 -> 99.85` (`|delta| = 4.4573`)

## Re-check Commands

Use these for each transfer function after edits:

```bash
eval-final <xfer-file> --domain <Domain> --op <Op-file> --exact-bw 7 --norm-bw 64,10000,1000
eval-final <xfer-file> --domain <Domain> --op <Op-file> --exact-bw 7,2000 --norm-bw 64,10000,1000
```
