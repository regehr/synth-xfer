define [2 x i4] @"meet"([2 x i4] %".1", [2 x i4] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"arg00" = extractvalue [2 x i4] %".1", 0
  %"arg01" = extractvalue [2 x i4] %".1", 1
  %"arg10" = extractvalue [2 x i4] %".2", 0
  %"arg11" = extractvalue [2 x i4] %".2", 1
  %"min0_cmp" = icmp ugt i4 %"arg00", %"arg10"
  %"min0" = select  i1 %"min0_cmp", i4 %"arg00", i4 %"arg10"
  %"max0_cmp" = icmp ult i4 %"arg01", %"arg11"
  %"max0" = select  i1 %"max0_cmp", i4 %"arg01", i4 %"arg11"
  %"result" = insertvalue [2 x i4] zeroinitializer, i4 %"min0", 0
  %"result.1" = insertvalue [2 x i4] %"result", i4 %"max0", 1
  ret [2 x i4] %"result.1"
}
