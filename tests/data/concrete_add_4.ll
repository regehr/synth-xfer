define i4 @"concrete_op"(i4 %".1", i4 %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %".4" = add i4 %".1", %".2"
  ret i4 %".4"
}
