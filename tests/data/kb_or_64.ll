define [2 x i64] @"kb_or"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs0" = extractvalue [2 x i64] %".1", 0
  %"lhs1" = extractvalue [2 x i64] %".1", 1
  %"rhs0" = extractvalue [2 x i64] %".2", 0
  %"rhs1" = extractvalue [2 x i64] %".2", 1
  %".4" = and i64 %"lhs0", %"rhs0"
  %".5" = or i64 %"lhs1", %"rhs1"
  %"r" = insertvalue [2 x i64] zeroinitializer, i64 %".4", 0
  %"r.1" = insertvalue [2 x i64] %"r", i64 %".5", 1
  ret [2 x i64] %"r.1"
}
