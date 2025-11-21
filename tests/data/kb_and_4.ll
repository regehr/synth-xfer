define [2 x i4] @"kb_and"([2 x i4] %".1", [2 x i4] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs0" = extractvalue [2 x i4] %".1", 0
  %"lhs1" = extractvalue [2 x i4] %".1", 1
  %"rhs0" = extractvalue [2 x i4] %".2", 0
  %"rhs1" = extractvalue [2 x i4] %".2", 1
  %".4" = or i4 %"lhs0", %"rhs0"
  %".5" = and i4 %"lhs1", %"rhs1"
  %"r" = insertvalue [2 x i4] zeroinitializer, i4 %".4", 0
  %"r.1" = insertvalue [2 x i4] %"r", i4 %".5", 1
  ret [2 x i4] %"r.1"
}
