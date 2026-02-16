# SYNTH Status

Generated: 2026-02-16 18:50:18 UTC

## KnownBits

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify-upto --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
[run] KnownBits Add: eval-final
[run] KnownBits Add: verify-upto
| `Add` | `tests/data/kb_add.mlir` | 100.0 | 0 | 37 | incomplete/unknown verify output |
[run] KnownBits AddNsw: eval-final
[run] KnownBits AddNsw: verify-upto
| `AddNsw` | `tests/data/kb_addnsw.mlir` | 95.392653 | 0 | 79 | incomplete/unknown verify output |
| `AddNswNuw` | — | missing | — | — | transfer file not present |
| `AddNuw` | — | missing | — | — | transfer file not present |
[run] KnownBits And: eval-final
[run] KnownBits And: verify-upto
| `And` | `tests/data/kb_and.mlir` | 100.0 | 0 | 8 | incomplete/unknown verify output |
[run] KnownBits Ashr: eval-final
[run] KnownBits Ashr: verify-upto
| `Ashr` | `tests/data/kb_ashr.mlir` | 99.268404 | 0 | 132 | incomplete/unknown verify output |
| `AshrExact` | — | missing | — | — | transfer file not present |
| `AvgCeilS` | — | missing | — | — | transfer file not present |
| `AvgCeilU` | — | missing | — | — | transfer file not present |
| `AvgFloorS` | — | missing | — | — | transfer file not present |
| `AvgFloorU` | — | missing | — | — | transfer file not present |
| `CountLOne` | — | missing | — | — | transfer file not present |
| `CountLZero` | — | missing | — | — | transfer file not present |
| `CountROne` | — | missing | — | — | transfer file not present |
| `CountRZero` | — | missing | — | — | transfer file not present |
| `Fshl` | — | missing | — | — | transfer file not present |
| `Fshr` | — | missing | — | — | transfer file not present |
| `Lerp` | — | missing | — | — | transfer file not present |
| `Lshr` | — | missing | — | — | transfer file not present |
| `LshrExact` | — | missing | — | — | transfer file not present |
[run] KnownBits Mods: eval-final
[run] KnownBits Mods: verify-upto
| `Mods` | `tests/data/kb_mods.mlir` | 66.528614 | 0 | 75 | incomplete/unknown verify output |
| `Modu` | — | missing | — | — | transfer file not present |
[run] KnownBits Mul: eval-final
[run] KnownBits Mul: verify-upto
| `Mul` | `tests/data/kb_mul.mlir` | 57.007164 | 0 | 55 | verify command error |
| `MulNsw` | — | missing | — | — | transfer file not present |
| `MulNswNuw` | — | missing | — | — | transfer file not present |
| `MulNuw` | — | missing | — | — | transfer file not present |
| `Nop` | — | missing | — | — | transfer file not present |
[run] KnownBits Or: eval-final
[run] KnownBits Or: verify-upto
| `Or` | `tests/data/kb_or.mlir` | 100.0 | 0 | 8 | incomplete/unknown verify output |
| `PopCount` | — | missing | — | — | transfer file not present |
| `Rotl` | — | missing | — | — | transfer file not present |
| `Rotr` | — | missing | — | — | transfer file not present |
| `SaddSat` | — | missing | — | — | transfer file not present |
| `Sdiv` | — | missing | — | — | transfer file not present |
[run] KnownBits SdivExact: eval-final
[run] KnownBits SdivExact: verify-upto
| `SdivExact` | `tests/data/kb_sdivexact.mlir` | 14.111862 | 0 | 81 | incomplete/unknown verify output |
| `Shl` | — | missing | — | — | transfer file not present |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
[run] KnownBits SshlSat: eval-final
[run] KnownBits SshlSat: verify-upto
| `SshlSat` | `tests/data/kb_sshlsat.mlir` | 93.669288 | 0 | 456 | incomplete/unknown verify output |
| `SsubSat` | — | missing | — | — | transfer file not present |
| `Sub` | — | missing | — | — | transfer file not present |
| `SubNsw` | — | missing | — | — | transfer file not present |
| `SubNswNuw` | — | missing | — | — | transfer file not present |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
[run] KnownBits UdivExact: eval-final
[run] KnownBits UdivExact: verify-upto
| `UdivExact` | `tests/data/kb_udivexact.mlir` | 95.945949 | 0 | 4879 | incomplete/unknown verify output |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
[run] KnownBits Xor: eval-final
[run] KnownBits Xor: verify-upto
| `Xor` | `tests/data/kb_xor.mlir` | 100.0 | 0 | 12 | incomplete/unknown verify output |

## UConstRange

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify-upto --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
[run] UConstRange Add: eval-final
[run] UConstRange Add: verify-upto
| `Add` | `tests/data/ucr_add.mlir` | 100.0 | 0 | 17 | incomplete/unknown verify output |
| `AddNsw` | — | missing | — | — | transfer file not present |
[run] UConstRange AddNswNuw: eval-final
[run] UConstRange AddNswNuw: verify-upto
| `AddNswNuw` | `tests/data/ucr_addnswnuw.mlir` | ... | 0 | 54 | incomplete/unknown verify output |
[run] UConstRange AddNuw: eval-final
[run] UConstRange AddNuw: verify-upto
| `AddNuw` | `tests/data/ucr_addnuw.mlir` | 100.0 | 0 | 17 | incomplete/unknown verify output |
[run] UConstRange And: eval-final
[run] UConstRange And: verify-upto
| `And` | `tests/data/ucr_and.mlir` | 75.482397 | 0 | 437 | verify command error |
| `Ashr` | — | missing | — | — | transfer file not present |
| `AshrExact` | — | missing | — | — | transfer file not present |
[run] UConstRange AvgCeilS: eval-final
[run] UConstRange AvgCeilS: verify-upto
| `AvgCeilS` | `tests/data/ucr_avgceils.mlir` | ... | 0 | 83 | incomplete/unknown verify output |
| `AvgCeilU` | — | missing | — | — | transfer file not present |
| `AvgFloorS` | — | missing | — | — | transfer file not present |
| `AvgFloorU` | — | missing | — | — | transfer file not present |
| `CountLOne` | — | missing | — | — | transfer file not present |
| `CountLZero` | — | missing | — | — | transfer file not present |
| `CountROne` | — | missing | — | — | transfer file not present |
| `CountRZero` | — | missing | — | — | transfer file not present |
| `Fshl` | — | missing | — | — | transfer file not present |
| `Fshr` | — | missing | — | — | transfer file not present |
| `Lerp` | — | missing | — | — | transfer file not present |
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
[run] UConstRange Shl: eval-final
[run] UConstRange Shl: verify-upto
| `Shl` | `tests/data/ucr_shl.mlir` | 99.999727 | 0 | 129 | incomplete/unknown verify output |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
| `SshlSat` | — | missing | — | — | transfer file not present |
| `SsubSat` | — | missing | — | — | transfer file not present |
[run] UConstRange Sub: eval-final
[run] UConstRange Sub: verify-upto
| `Sub` | `tests/data/ucr_sub.mlir` | 100.0 | 0 | 15 | incomplete/unknown verify output |
| `SubNsw` | — | missing | — | — | transfer file not present |
[run] UConstRange SubNswNuw: eval-final
[run] UConstRange SubNswNuw: verify-upto
| `SubNswNuw` | `tests/data/ucr_subnswnuw.mlir` | ... | 0 | 60 | incomplete/unknown verify output |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
[run] UConstRange UdivExact: eval-final
[run] UConstRange UdivExact: verify-upto
| `UdivExact` | `tests/data/ucr_udivexact.mlir` | ... | 0 | 35 | incomplete/unknown verify output |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
[run] UConstRange Xor: eval-final
[run] UConstRange Xor: verify-upto
| `Xor` | `tests/data/ucr_xor.mlir` | 51.9463 | 0 | 42 | incomplete/unknown verify output |

## SConstRange

| Op | Transfer File | Exact Precision (`--exact-bw 7`, Synth Exact %) | Highest Sound BW (`verify-upto --timeout 120`) | MLIR Inst Count | Notes |
|---|---|---:|---:|---:|---|
| `Abds` | — | missing | — | — | transfer file not present |
| `Abdu` | — | missing | — | — | transfer file not present |
| `Add` | — | missing | — | — | transfer file not present |
| `AddNsw` | — | missing | — | — | transfer file not present |
[run] SConstRange AddNswNuw: eval-final
[run] SConstRange AddNswNuw: verify-upto
| `AddNswNuw` | `tests/data/scr_addnswnuw.mlir` | ... | 0 | 57 | incomplete/unknown verify output |
| `AddNuw` | — | missing | — | — | transfer file not present |
[run] SConstRange And: eval-final
[run] SConstRange And: verify-upto
| `And` | `tests/data/scr_and.mlir` | 64.144194 | 0 | 429 | verify command error |
| `Ashr` | — | missing | — | — | transfer file not present |
| `AshrExact` | — | missing | — | — | transfer file not present |
[run] SConstRange AvgCeilS: eval-final
[run] SConstRange AvgCeilS: verify-upto
| `AvgCeilS` | `tests/data/scr_avgceils.mlir` | ... | 0 | 15 | incomplete/unknown verify output |
| `AvgCeilU` | — | missing | — | — | transfer file not present |
| `AvgFloorS` | — | missing | — | — | transfer file not present |
| `AvgFloorU` | — | missing | — | — | transfer file not present |
| `CountLOne` | — | missing | — | — | transfer file not present |
| `CountLZero` | — | missing | — | — | transfer file not present |
| `CountROne` | — | missing | — | — | transfer file not present |
| `CountRZero` | — | missing | — | — | transfer file not present |
| `Fshl` | — | missing | — | — | transfer file not present |
| `Fshr` | — | missing | — | — | transfer file not present |
| `Lerp` | — | missing | — | — | transfer file not present |
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
[run] SConstRange SdivExact: eval-final
[run] SConstRange SdivExact: verify-upto
| `SdivExact` | `tests/data/scr_sdivexact.mlir` | ... | 0 | 162 | incomplete/unknown verify output |
[run] SConstRange Shl: eval-final
[run] SConstRange Shl: verify-upto
| `Shl` | `tests/data/scr_shl.mlir` | 46.355066 | 0 | 85 | incomplete/unknown verify output |
| `ShlNsw` | — | missing | — | — | transfer file not present |
| `ShlNswNuw` | — | missing | — | — | transfer file not present |
| `ShlNuw` | — | missing | — | — | transfer file not present |
| `Smax` | — | missing | — | — | transfer file not present |
| `Smin` | — | missing | — | — | transfer file not present |
| `SmulSat` | — | missing | — | — | transfer file not present |
| `Square` | — | missing | — | — | transfer file not present |
| `SshlSat` | — | missing | — | — | transfer file not present |
| `SsubSat` | — | missing | — | — | transfer file not present |
[run] SConstRange Sub: eval-final
[run] SConstRange Sub: verify-upto
| `Sub` | `tests/data/scr_sub.mlir` | 100.0 | 0 | 17 | incomplete/unknown verify output |
| `SubNsw` | — | missing | — | — | transfer file not present |
[run] SConstRange SubNswNuw: eval-final
[run] SConstRange SubNswNuw: verify-upto
| `SubNswNuw` | `tests/data/scr_subnswnuw.mlir` | ... | 0 | 67 | incomplete/unknown verify output |
| `SubNuw` | — | missing | — | — | transfer file not present |
| `UaddSat` | — | missing | — | — | transfer file not present |
| `Udiv` | — | missing | — | — | transfer file not present |
| `UdivExact` | — | missing | — | — | transfer file not present |
| `Umax` | — | missing | — | — | transfer file not present |
| `Umin` | — | missing | — | — | transfer file not present |
| `UmulSat` | — | missing | — | — | transfer file not present |
| `UshlSat` | — | missing | — | — | transfer file not present |
| `UsubSat` | — | missing | — | — | transfer file not present |
[run] SConstRange Xor: eval-final
[run] SConstRange Xor: verify-upto
| `Xor` | `tests/data/scr_xor.mlir` | 54.887049 | 0 | 54 | incomplete/unknown verify output |

