; ModuleID = ""
target triple = "unknown-unknown-unknown"
target datalayout = ""

define [2 x i4] @"cr_add"([2 x i4] %".1", [2 x i4] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs_lower" = extractvalue [2 x i4] %".1", 0
  %"lhs_upper" = extractvalue [2 x i4] %".1", 1
  %"rhs_lower" = extractvalue [2 x i4] %".2", 0
  %"rhs_upper" = extractvalue [2 x i4] %".2", 1
  %".4" = add i4 %"lhs_lower", %"rhs_lower"
  %".5" = add i4 %"lhs_upper", %"rhs_upper"
  %"res_lower_ov_ov" = call {i4, i1} @"llvm.uadd.with.overflow.i4"(i4 %"lhs_lower", i4 %"rhs_lower")
  %"res_lower_ov" = extractvalue {i4, i1} %"res_lower_ov_ov", 1
  %"res_upper_ov_ov" = call {i4, i1} @"llvm.uadd.with.overflow.i4"(i4 %"lhs_upper", i4 %"rhs_upper")
  %"res_upper_ov" = extractvalue {i4, i1} %"res_upper_ov_ov", 1
  %"lower_ge_upper" = icmp ugt i4 %".4", %".5"
  %".6" = xor i1 %"res_lower_ov", %"res_upper_ov"
  %".7" = or i1 %"lower_ge_upper", %".6"
  %".8" = select  i1 %".7", i4 0, i4 %".4"
  %".9" = select  i1 %".7", i4 15, i4 %".5"
  %"r" = insertvalue [2 x i4] zeroinitializer, i4 %".8", 0
  %"r.1" = insertvalue [2 x i4] %"r", i4 %".9", 1
  ret [2 x i4] %"r.1"
}

declare {i4, i1} @"llvm.uadd.with.overflow.i4"(i4 %".1", i4 %".2")

define [2 x i64] @"cr_add_shim"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
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
  %".16" = call [2 x i4] @"cr_add"([2 x i4] %".9", [2 x i4] %".15")
  %".17" = extractvalue [2 x i4] %".16", 0
  %".18" = zext i4 %".17" to i64
  %".19" = extractvalue [2 x i4] %".16", 1
  %".20" = zext i4 %".19" to i64
  %".21" = insertvalue [2 x i64] zeroinitializer, i64 %".18", 0
  %".22" = insertvalue [2 x i64] %".21", i64 %".20", 1
  ret [2 x i64] %".22"
}
