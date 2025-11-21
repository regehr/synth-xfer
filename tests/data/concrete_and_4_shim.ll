define i64 @"concrete_op_shim"(i64 %"a64", i64 %"b64") alwaysinline norecurse nounwind readnone
{
entry:
  %".4" = trunc i64 %"a64" to i4
  %".5" = trunc i64 %"b64" to i4
  %".6" = call i4 @"concrete_op"(i4 %".4", i4 %".5")
  %".7" = zext i4 %".6" to i64
  ret i64 %".7"
}
