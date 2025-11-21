define [2 x i4] @"getTop"([2 x i4] %".1") alwaysinline norecurse nounwind readnone
{
entry:
  %"arg00" = extractvalue [2 x i4] %".1", 0
  %".3" = sub i4 0, 1
  %"result" = insertvalue [2 x i4] zeroinitializer, i4 0, 0
  %"result.1" = insertvalue [2 x i4] %"result", i4 %".3", 1
  ret [2 x i4] %"result.1"
}
