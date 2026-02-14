"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_min_tz_ub = "transfer.countr_one"(%rhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_min_nonzero_cand = "transfer.shl"(%const1, %rhs_min_tz_ub) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_min_safe = "transfer.select"(%rhs1_is_zero, %rhs_min_nonzero_cand, %rhs1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %max_res = "transfer.udiv"(%lhs_max, %rhs_min_safe) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %leadz = "transfer.countl_zero"(%max_res) : (!transfer.integer) -> !transfer.integer
    %leadz_inv = "transfer.sub"(%bitwidth, %leadz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %high_zero_mask = "transfer.shl"(%all_ones, %leadz_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_min_tz = "transfer.countr_one"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %lhs_max_tz = "transfer.countr_zero"(%lhs1) : (!transfer.integer) -> !transfer.integer
    %rhs_max_tz = "transfer.countr_zero"(%rhs1) : (!transfer.integer) -> !transfer.integer

    %min_nonneg = "transfer.cmp"(%lhs_min_tz, %rhs_max_tz) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %max_neg = "transfer.cmp"(%lhs_max_tz, %rhs_min_tz_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %min_tz = "transfer.sub"(%lhs_min_tz, %rhs_max_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_tz = "transfer.sub"(%lhs_max_tz, %rhs_min_tz_ub) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %min_tz_inv = "transfer.sub"(%bitwidth, %min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_zero_cand = "transfer.lshr"(%all_ones, %min_tz_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_zero_mask = "transfer.select"(%min_nonneg, %low_zero_cand, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %min_eq_max = "transfer.cmp"(%min_tz, %max_tz) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %min_lt_bw = "transfer.cmp"(%min_tz, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %min_nonneg_and_eq = "arith.andi"(%min_nonneg, %min_eq_max) : (i1, i1) -> i1
    %exact_tz_one = "arith.andi"(%min_nonneg_and_eq, %min_lt_bw) : (i1, i1) -> i1
    %exact_tz_one_cand = "transfer.shl"(%const1, %min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %exact_tz_one_mask = "transfer.select"(%exact_tz_one, %exact_tz_one_cand, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_bit0_one = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_odd = "transfer.cmp"(%lhs_bit0_one, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %odd_one_mask = "transfer.select"(%lhs_odd, %const1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_base = "transfer.or"(%high_zero_mask, %low_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_tz = "transfer.or"(%exact_tz_one_mask, %odd_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_minus_1 = "transfer.sub"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_and_minus_1 = "transfer.and"(%rhs1, %rhs1_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_and_minus_1_is_zero = "transfer.cmp"(%rhs1_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_const_pow2 = "arith.andi"(%rhs_is_const, %rhs1_and_minus_1_is_zero) : (i1, i1) -> i1
    %lhs0_lshr = "transfer.lshr"(%lhs0, %rhs_max_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs1_lshr = "transfer.lshr"(%lhs1, %rhs_max_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_lshr_ones = "transfer.lshr"(%all_ones, %rhs_max_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_high_zero = "transfer.xor"(%pow2_lshr_ones, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_pow2 = "transfer.or"(%lhs0_lshr, %pow2_high_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1
    %rhs_const_safe = "transfer.select"(%rhs1_is_zero, %const1, %rhs1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %quot_const = "transfer.udiv"(%lhs1, %rhs_const_safe) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_const = "transfer.xor"(%quot_const, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_base_pow2 = "transfer.select"(%rhs_const_pow2, %res0_pow2, %res0_base) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_base_pow2 = "transfer.select"(%rhs_const_pow2, %lhs1_lshr, %res1_tz) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_base_const = "transfer.select"(%both_const, %res0_const, %res0_base_pow2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_base_const = "transfer.select"(%both_const, %quot_const, %res1_base_pow2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1

    %not_const1 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs0_is_not1 = "transfer.cmp"(%rhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_1 = "transfer.cmp"(%rhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_one = "arith.andi"(%rhs0_is_not1, %rhs1_is_1) : (i1, i1) -> i1

    %res0_rhs_one = "transfer.select"(%rhs_is_one, %lhs0, %res0_base_const) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_one = "transfer.select"(%rhs_is_one, %lhs1, %res1_base_const) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_zero = "transfer.select"(%lhs_is_zero, %all_ones, %res0_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_zero = "transfer.select"(%lhs_is_zero, %const0, %res1_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%max_neg, %all_ones, %res0_zero) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%max_neg, %const0, %res1_zero) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_udivexact", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
