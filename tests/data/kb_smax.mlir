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
    %const_res1 = "transfer.smax"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %smin = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %smax = "transfer.get_signed_max_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %smin_not = "transfer.xor"(%smin, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %smax_not = "transfer.xor"(%smax, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_is_smin_not = "transfer.cmp"(%lhs0, %smin_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_smin = "transfer.cmp"(%lhs1, %smin) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_smin = "arith.andi"(%lhs0_is_smin_not, %lhs1_is_smin) : (i1, i1) -> i1
    %rhs0_is_smin_not = "transfer.cmp"(%rhs0, %smin_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_smin = "transfer.cmp"(%rhs1, %smin) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_smin = "arith.andi"(%rhs0_is_smin_not, %rhs1_is_smin) : (i1, i1) -> i1

    %lhs0_is_smax_not = "transfer.cmp"(%lhs0, %smax_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_smax = "transfer.cmp"(%lhs1, %smax) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_smax = "arith.andi"(%lhs0_is_smax_not, %lhs1_is_smax) : (i1, i1) -> i1
    %rhs0_is_smax_not = "transfer.cmp"(%rhs0, %smax_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_smax = "transfer.cmp"(%rhs1, %smax) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_smax = "arith.andi"(%rhs0_is_smax_not, %rhs1_is_smax) : (i1, i1) -> i1

    %res0_lhs_smin = "transfer.select"(%lhs_is_smin, %rhs0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lhs_smin = "transfer.select"(%lhs_is_smin, %rhs1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_rhs_smin = "transfer.select"(%rhs_is_smin, %lhs0, %res0_lhs_smin) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_smin = "transfer.select"(%rhs_is_smin, %lhs1, %res1_lhs_smin) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_lhs_smax = "transfer.select"(%lhs_is_smax, %smax_not, %res0_rhs_smin) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lhs_smax = "transfer.select"(%lhs_is_smax, %smax, %res1_rhs_smin) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_rhs_smax = "transfer.select"(%rhs_is_smax, %smax_not, %res0_lhs_smax) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_smax = "transfer.select"(%rhs_is_smax, %smax, %res1_lhs_smax) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_res0, %res0_rhs_smax) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_res1, %res1_rhs_smax) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_smax", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
