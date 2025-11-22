; ModuleID = ""
target triple = "unknown-unknown-unknown"
target datalayout = ""

define [2 x i4] @"kb_or"([2 x i4] %".1", [2 x i4] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs0" = extractvalue [2 x i4] %".1", 0
  %"lhs1" = extractvalue [2 x i4] %".1", 1
  %"rhs0" = extractvalue [2 x i4] %".2", 0
  %"rhs1" = extractvalue [2 x i4] %".2", 1
  %".4" = and i4 %"lhs0", %"rhs0"
  %".5" = or i4 %"lhs1", %"rhs1"
  %"r" = insertvalue [2 x i4] zeroinitializer, i4 %".4", 0
  %"r.1" = insertvalue [2 x i4] %"r", i4 %".5", 1
  ret [2 x i4] %"r.1"
}

define [2 x i64] @"kb_or_shim"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %".4" = extractvalue [2 x i64] %".1", 0
  %".5" = trunc i64 %".4" to i4
  %".6" = extractvalue [2 x i64] %".1", 1
  %".7" = trunc i64 %".6" to i4
  %".8" = insertvalue [2 x i4] zeroinitializer, i4 %".5", 0
  %".9" = insertvalue [2 x i4] %".8", i4 %".7", 1
  %".10" = extractvalue [2 x i64] %".2", 0
  %".11" = trunc i64 %".10" to i4
  %".12" = extractvalue [2 x i64] %".2", 1
  %".13" = trunc i64 %".12" to i4
  %".14" = insertvalue [2 x i4] zeroinitializer, i4 %".11", 0
  %".15" = insertvalue [2 x i4] %".14", i4 %".13", 1
  %".16" = call [2 x i4] @"kb_or"([2 x i4] %".9", [2 x i4] %".15")
  %".17" = extractvalue [2 x i4] %".16", 0
  %".18" = zext i4 %".17" to i64
  %".19" = extractvalue [2 x i4] %".16", 1
  %".20" = zext i4 %".19" to i64
  %".21" = insertvalue [2 x i64] zeroinitializer, i64 %".18", 0
  %".22" = insertvalue [2 x i64] %".21", i64 %".20", 1
  ret [2 x i64] %".22"
}
