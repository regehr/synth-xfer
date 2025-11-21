define [2 x i64] @"kb_xor"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs0" = extractvalue [2 x i64] %".1", 0
  %"lhs1" = extractvalue [2 x i64] %".1", 1
  %"rhs0" = extractvalue [2 x i64] %".2", 0
  %"rhs1" = extractvalue [2 x i64] %".2", 1
  %".4" = and i64 %"lhs0", %"rhs0"
  %".5" = and i64 %"lhs1", %"rhs1"
  %".6" = and i64 %"lhs0", %"rhs1"
  %".7" = and i64 %"lhs1", %"rhs0"
  %".8" = or i64 %".4", %".5"
  %".9" = or i64 %".6", %".7"
  %"r" = insertvalue [2 x i64] zeroinitializer, i64 %".8", 0
  %"r.1" = insertvalue [2 x i64] %"r", i64 %".9", 1
  ret [2 x i64] %"r.1"
}
