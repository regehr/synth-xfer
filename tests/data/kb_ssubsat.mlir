"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1

    %rhs0_all_ones = "transfer.cmp"(%rhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_zero = "arith.andi"(%rhs0_all_ones, %rhs1_is_zero) : (i1, i1) -> i1

    %signed_max = "transfer.get_signed_max_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %signed_min = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %sub_res = "transfer.sub"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %overflow = "transfer.ssub_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_neg = "transfer.is_negative"(%lhs1) : (!transfer.integer) -> i1
    %sat_res = "transfer.select"(%lhs_is_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1 = "transfer.select"(%overflow, %sat_res, %sub_res) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_rhs_zero = "transfer.select"(%rhs_is_zero, %lhs0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_zero = "transfer.select"(%rhs_is_zero, %lhs1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_res0, %res0_rhs_zero) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_res1, %res1_rhs_zero) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_ssubsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
