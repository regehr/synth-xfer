define [2 x i64] @"cr_add_shim"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %".4" = extractvalue [2 x i64] %".1", 0
  %".5" = trunc i64 %".4" to i4
  %".6" = extractvalue [2 x i64] %".1", 1
  %".7" = trunc i64 %".6" to i4
  %".8" = extractvalue [2 x i64] %".2", 0
  %".9" = trunc i64 %".8" to i4
  %".10" = extractvalue [2 x i64] %".2", 1
  %".11" = trunc i64 %".10" to i4
  %".12" = insertvalue [2 x i4] zeroinitializer, i4 %".5", 0
  %".13" = insertvalue [2 x i4] %".12", i4 %".7", 1
  %".14" = insertvalue [2 x i4] zeroinitializer, i4 %".9", 0
  %".15" = insertvalue [2 x i4] %".14", i4 %".11", 1
  %".16" = call [2 x i4] @"cr_add"([2 x i4] %".13", [2 x i4] %".15")
  %".17" = extractvalue [2 x i4] %".16", 0
  %".18" = zext i4 %".17" to i64
  %".19" = extractvalue [2 x i4] %".16", 1
  %".20" = zext i4 %".19" to i64
  %".21" = insertvalue [2 x i64] zeroinitializer, i64 %".18", 0
  %".22" = insertvalue [2 x i64] %".21", i64 %".20", 1
  ret [2 x i64] %".22"
}
