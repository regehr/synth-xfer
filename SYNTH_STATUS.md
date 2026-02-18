# SYNTH Status

Generated: 2026-02-18 00:46:00 UTC

## KnownBits

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify-upto --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | `tests/data/kb_abds.mlir` | 83.371416 | 64 | 226 | sound through bw 64 |
| `Abdu` | `tests/data/kb_abdu.mlir` | 91.937602 | 64 | 189 | sound through bw 64 |
| `Add` | `tests/data/kb_add.mlir` | 100.0 | 64 | 37 | sound through bw 64 |
| `AddNsw` | `tests/data/kb_addnsw.mlir` | 95.392653 | 64 | 79 | sound through bw 64 |
| `AddNswNuw` | `tests/data/kb_addnswnuw.mlir` | 93.384757 | 64 | 181 | sound through bw 64 |
| `AddNuw` | `tests/data/kb_addnuw.mlir` | 100.0 | 64 | 55 | sound through bw 64 |
| `And` | `tests/data/kb_and.mlir` | 100.0 | 64 | 8 | sound through bw 64 |
| `Ashr` | `tests/data/kb_ashr.mlir` | 99.268404 | 64 | 132 | sound through bw 64 |
| `AshrExact` | `tests/data/kb_ashrexact.mlir` | 95.515421 | 64 | 134 | sound through bw 64 |
| `AvgCeilS` | `tests/data/kb_avgceils.mlir` | 57.717602 | 64 | 99 | sound through bw 64 |
| `AvgCeilU` | `tests/data/kb_avgceilu.mlir` | 46.702519 | 64 | 88 | sound through bw 64 |
| `AvgFloorS` | `tests/data/kb_avgfloors.mlir` | 72.531371 | 64 | 66 | sound through bw 64 |
| `AvgFloorU` | `tests/data/kb_avgflooru.mlir` | 54.572944 | 64 | 55 | sound through bw 64 |
| `CountLOne` | `tests/data/kb_countlone.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `CountLZero` | `tests/data/kb_countlzero.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `CountROne` | `tests/data/kb_countrone.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `CountRZero` | `tests/data/kb_countrzero.mlir` | 90.946502 | 64 | 20 | sound through bw 64 |
| `Fshl` | `tests/data/kb_fshl.mlir` | 71.086341 | 5 | 51 | sound through bw 5 (ternary cap; exact run used `--exact-bw 5`) |
| `Fshr` | `tests/data/kb_fshr.mlir` | 71.086341 | 5 | 51 | sound through bw 5 (ternary cap; exact run used `--exact-bw 5`) |
| `Lshr` | `tests/data/kb_lshr.mlir` | 100.0 | 64 | 246 | sound through bw 64 |
| `LshrExact` | `tests/data/kb_lshrexact.mlir` | 100.0 | 64 | 277 | sound through bw 64 |
| `Mods` | `tests/data/kb_mods.mlir` | 66.528614 | 31 | 75 | stopped at bw 32 (timeout) |
| `Modu` | `tests/data/kb_modu.mlir` | 98.803944 | 6 | 1698 | stopped at bw 7 (timeout) |
| `Mul` | `tests/data/kb_mul.mlir` | 57.007164 | 0 | 55 | verify command error |
| `MulNsw` | `tests/data/kb_mulnsw.mlir` | 94.488507 | 8 | 2433 | stopped at bw 9 (timeout) |
| `MulNswNuw` | `tests/data/kb_mulnswnuw.mlir` | 92.084644 | 9 | 2945 | stopped at bw 10 (timeout) |
| `MulNuw` | `tests/data/kb_mulnuw.mlir` | 93.340977 | 9 | 2413 | stopped at bw 10 (timeout) |
| `Nop` | `tests/data/kb_nop.mlir` | 100.0 | 64 | 1 | sound through bw 64 |
| `Or` | `tests/data/kb_or.mlir` | 100.0 | 64 | 8 | sound through bw 64 |
| `PopCount` | — | missing | — | — | transfer file not present |
| `Rotl` | `tests/data/kb_rotl.mlir` | 78.36323 | 56 | 31 | stopped at bw 57 (timeout) |
| `Rotr` | `tests/data/kb_rotr.mlir` | 78.36323 | 52 | 31 | stopped at bw 53 (timeout) |
| `SaddSat` | `tests/data/kb_saddsat.mlir` | 56.514562 | 64 | 116 | sound through bw 64 |
| `Sdiv` | `tests/data/kb_sdiv.mlir` | 58.191073 | 17 | 29 | stopped at bw 18 (timeout) |
| `SdivExact` | `tests/data/kb_sdivexact.mlir` | 14.111862 | 41 | 81 | stopped at bw 42 (timeout) |
| `Shl` | `tests/data/kb_shl.mlir` | 2.036413 | 64 | 24 | sound through bw 64 |
| `ShlNsw` | `tests/data/kb_shlnsw.mlir` | 0.0 | 64 | 24 | sound through bw 64 |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | `tests/data/kb_shlnuw.mlir` | 0.002676 | 64 | 24 | sound through bw 64 |
| `Smax` | `tests/data/kb_smax.mlir` | 6.254128 | 64 | 41 | sound through bw 64 |
| `Smin` | `tests/data/kb_smin.mlir` | 6.254128 | 64 | 41 | sound through bw 64 |
| `SmulSat` | `tests/data/kb_smulsat.mlir` | 55.757334 | 15 | 47 | stopped at bw 16 (timeout) |
| `Square` | `tests/data/kb_square.mlir` | 5.852766 | 20 | 12 | stopped at bw 21 (timeout) |
| `SshlSat` | `tests/data/kb_sshlsat.mlir` | 93.669288 | 64 | 456 | sound through bw 64 |
| `SsubSat` | — | missing | — | — | transfer file not present |
| `Sub` | `tests/data/kb_sub.mlir` | 25.440579 | 64 | 22 | sound through bw 64 |
| `SubNsw` | `tests/data/kb_subnsw.mlir` | 19.091175 | 64 | 22 | sound through bw 64 |
| `SubNswNuw` | `tests/data/kb_subnswnuw.mlir` | 4.140253 | 64 | 22 | sound through bw 64 |
| `SubNuw` | `tests/data/kb_subnuw.mlir` | 10.787714 | 64 | 22 | sound through bw 64 |
| `UaddSat` | `tests/data/kb_uaddsat.mlir` | 63.743754 | 64 | 195 | sound through bw 64 |
| `Udiv` | `tests/data/kb_udiv.mlir` | 2.838195 | 18 | 31 | stopped at bw 19 (timeout) |
| `UdivExact` | `tests/data/kb_udivexact.mlir` | 95.945949 | 5 | 49453 | stopped at bw 6 (timeout) |
| `Umax` | `tests/data/kb_umax.mlir` | 100.0 | 64 | 80 | sound through bw 64 |
| `Umin` | `tests/data/kb_umin.mlir` | 100.0 | 64 | 80 | sound through bw 64 |
| `UmulSat` | `tests/data/kb_umulsat.mlir` | 89.259328 | 12 | 281 | stopped at bw 13 (timeout) |
| `UshlSat` | `tests/data/kb_ushlsat.mlir` | 94.948702 | 64 | 264 | sound through bw 64 |
| `UsubSat` | `tests/data/kb_usubsat.mlir` | 99.746183 | 64 | 314 | sound through bw 64 |
| `Xor` | `tests/data/kb_xor.mlir` | 100.0 | 64 | 12 | sound through bw 64 |

## UConstRange

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify-upto --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
| `Add` | `tests/data/ucr_add.mlir` | 100.0 | 64 | 17 | sound through bw 64 |
| `AddNsw` | — | missing | — | — | transfer file not present |
| `AddNswNuw` | `tests/data/ucr_addnswnuw.mlir` | 100.0 | 64 | 54 | sound through bw 64 |
| `AddNuw` | `tests/data/ucr_addnuw.mlir` | 100.0 | 64 | 17 | sound through bw 64 |
| `And` | `tests/data/ucr_and.mlir` | 75.482397 | 0 | 437 | verify command error |
| `Ashr` | — | missing | — | — | transfer file not present |
| `AshrExact` | — | missing | — | — | transfer file not present |
| `AvgCeilS` | `tests/data/ucr_avgceils.mlir` | 100.0 | 51 | 83 | stopped at bw 52 (timeout) |
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
| `Shl` | `tests/data/ucr_shl.mlir` | 99.999727 | 64 | 129 | sound through bw 64 |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
| `SshlSat` | — | missing | — | — | transfer file not present |
| `SsubSat` | — | missing | — | — | transfer file not present |
| `Sub` | `tests/data/ucr_sub.mlir` | 100.0 | 64 | 15 | sound through bw 64 |
| `SubNsw` | — | missing | — | — | transfer file not present |
| `SubNswNuw` | `tests/data/ucr_subnswnuw.mlir` | 100.0 | 64 | 60 | sound through bw 64 |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
| `UdivExact` | `tests/data/ucr_udivexact.mlir` | 83.04657 | 16 | 35 | stopped at bw 17 (timeout) |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
| `Xor` | `tests/data/ucr_xor.mlir` | 51.9463 | 64 | 42 | sound through bw 64 |

## SConstRange

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify-upto --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
| `Add` | — | missing | — | — | transfer file not present |
| `AddNsw` | — | missing | — | — | transfer file not present |
| `AddNswNuw` | `tests/data/scr_addnswnuw.mlir` | 100.0 | 64 | 57 | sound through bw 64 |
| `AddNuw` | — | missing | — | — | transfer file not present |
| `And` | `tests/data/scr_and.mlir` | 64.144194 | 0 | 429 | verify command error |
| `Ashr` | — | missing | — | — | transfer file not present |
| `AshrExact` | — | missing | — | — | transfer file not present |
| `AvgCeilS` | `tests/data/scr_avgceils.mlir` | 100.0 | 64 | 15 | sound through bw 64 |
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
| `SdivExact` | `tests/data/scr_sdivexact.mlir` | 24.318789 | 13 | 162 | stopped at bw 14 (timeout) |
| `Shl` | `tests/data/scr_shl.mlir` | 46.355066 | 64 | 85 | sound through bw 64 |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
| `SshlSat` | — | missing | — | — | transfer file not present |
| `SsubSat` | — | missing | — | — | transfer file not present |
| `Sub` | `tests/data/scr_sub.mlir` | 100.0 | 64 | 17 | sound through bw 64 |
| `SubNsw` | — | missing | — | — | transfer file not present |
| `SubNswNuw` | `tests/data/scr_subnswnuw.mlir` | 100.0 | 64 | 67 | sound through bw 64 |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
| `UdivExact` | — | missing | — | — | transfer file not present |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
| `Xor` | `tests/data/scr_xor.mlir` | 54.887049 | 64 | 54 | sound through bw 64 |
