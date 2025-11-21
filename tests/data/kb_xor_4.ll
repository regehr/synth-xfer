define [2 x i4] @"kb_xor"([2 x i4] %".1", [2 x i4] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs0" = extractvalue [2 x i4] %".1", 0
  %"lhs1" = extractvalue [2 x i4] %".1", 1
  %"rhs0" = extractvalue [2 x i4] %".2", 0
  %"rhs1" = extractvalue [2 x i4] %".2", 1
  %".4" = and i4 %"lhs0", %"rhs0"
  %".5" = and i4 %"lhs1", %"rhs1"
  %".6" = and i4 %"lhs0", %"rhs1"
  %".7" = and i4 %"lhs1", %"rhs0"
  %".8" = or i4 %".4", %".5"
  %".9" = or i4 %".6", %".7"
  %"r" = insertvalue [2 x i4] zeroinitializer, i4 %".8", 0
  %"r.1" = insertvalue [2 x i4] %"r", i4 %".9", 1
  ret [2 x i4] %"r.1"
}
