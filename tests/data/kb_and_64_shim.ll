define [2 x i64] @"kb_and_shim"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %".4" = extractvalue [2 x i64] %".1", 0
  %".5" = extractvalue [2 x i64] %".1", 1
  %".6" = extractvalue [2 x i64] %".2", 0
  %".7" = extractvalue [2 x i64] %".2", 1
  %".8" = insertvalue [2 x i64] zeroinitializer, i64 %".4", 0
  %".9" = insertvalue [2 x i64] %".8", i64 %".5", 1
  %".10" = insertvalue [2 x i64] zeroinitializer, i64 %".6", 0
  %".11" = insertvalue [2 x i64] %".10", i64 %".7", 1
  %".12" = call [2 x i64] @"kb_and"([2 x i64] %".9", [2 x i64] %".11")
  %".13" = extractvalue [2 x i64] %".12", 0
  %".14" = extractvalue [2 x i64] %".12", 1
  %".15" = insertvalue [2 x i64] zeroinitializer, i64 %".13", 0
  %".16" = insertvalue [2 x i64] %".15", i64 %".14", 1
  ret [2 x i64] %".16"
}
