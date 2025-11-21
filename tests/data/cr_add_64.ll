define [2 x i64] @"cr_add"([2 x i64] %".1", [2 x i64] %".2") alwaysinline norecurse nounwind readnone
{
entry:
  %"lhs_lower" = extractvalue [2 x i64] %".1", 0
  %"lhs_upper" = extractvalue [2 x i64] %".1", 1
  %"rhs_lower" = extractvalue [2 x i64] %".2", 0
  %"rhs_upper" = extractvalue [2 x i64] %".2", 1
  %".4" = add i64 %"lhs_lower", %"rhs_lower"
  %".5" = add i64 %"lhs_upper", %"rhs_upper"
  %"res_lower_ov_ov" = call {i64, i1} @"llvm.uadd.with.overflow.i64"(i64 %"lhs_lower", i64 %"rhs_lower")
  %"res_lower_ov" = extractvalue {i64, i1} %"res_lower_ov_ov", 1
  %"res_upper_ov_ov" = call {i64, i1} @"llvm.uadd.with.overflow.i64"(i64 %"lhs_upper", i64 %"rhs_upper")
  %"res_upper_ov" = extractvalue {i64, i1} %"res_upper_ov_ov", 1
  %"lower_ge_upper" = icmp ugt i64 %".4", %".5"
  %".6" = xor i1 %"res_lower_ov", %"res_upper_ov"
  %".7" = or i1 %"lower_ge_upper", %".6"
  %".8" = select  i1 %".7", i64 0, i64 %".4"
  %".9" = select  i1 %".7", i64 18446744073709551615, i64 %".5"
  %"r" = insertvalue [2 x i64] zeroinitializer, i64 %".8", 0
  %"r.1" = insertvalue [2 x i64] %"r", i64 %".9", 1
  ret [2 x i64] %"r.1"
}
