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

    %lhs_min_tz = "transfer.countr_one"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %lhs_max_tz = "transfer.countr_zero"(%lhs1) : (!transfer.integer) -> !transfer.integer
    %rhs_min_tz = "transfer.countr_one"(%rhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_max_tz = "transfer.countr_zero"(%rhs1) : (!transfer.integer) -> !transfer.integer

    %min_nonneg = "transfer.cmp"(%lhs_min_tz, %rhs_max_tz) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %min_tz = "transfer.sub"(%lhs_min_tz, %rhs_max_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_tz_inv = "transfer.sub"(%bitwidth, %min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_zero_cand = "transfer.lshr"(%all_ones, %min_tz_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_zero_mask = "transfer.select"(%min_nonneg, %low_zero_cand, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %max_tz = "transfer.sub"(%lhs_max_tz, %rhs_min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_eq_max = "transfer.cmp"(%min_tz, %max_tz) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %min_lt_bw = "transfer.cmp"(%min_tz, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %exact_tz_pre = "arith.andi"(%min_nonneg, %min_eq_max) : (i1, i1) -> i1
    %exact_tz_one = "arith.andi"(%exact_tz_pre, %min_lt_bw) : (i1, i1) -> i1
    %exact_tz_one_cand = "transfer.shl"(%const1, %min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %exact_tz_one_mask = "transfer.select"(%exact_tz_one, %exact_tz_one_cand, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_bit0_one = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_odd = "transfer.cmp"(%lhs_bit0_one, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %odd_one_mask = "transfer.select"(%lhs_odd, %const1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res1_tz = "transfer.or"(%exact_tz_one_mask, %odd_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sign_mask = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %lhs_nonneg = "transfer.cmp"(%lhs0, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_neg = "transfer.cmp"(%lhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_nonneg = "transfer.cmp"(%rhs0, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_neg = "transfer.cmp"(%rhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %lhs_nz = "transfer.cmp"(%lhs1, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %sign_zero_nn = "arith.andi"(%lhs_nonneg, %rhs_nonneg) : (i1, i1) -> i1
    %sign_zero_pp = "arith.andi"(%lhs_neg, %rhs_neg) : (i1, i1) -> i1
    %sign_zero_known = "arith.ori"(%sign_zero_nn, %sign_zero_pp) : (i1, i1) -> i1

    %sign_one_np = "arith.andi"(%lhs_nonneg, %rhs_neg) : (i1, i1) -> i1
    %sign_one_pn = "arith.andi"(%lhs_neg, %rhs_nonneg) : (i1, i1) -> i1
    %sign_one_pre = "arith.ori"(%sign_one_np, %sign_one_pn) : (i1, i1) -> i1
    %sign_one_known = "arith.andi"(%sign_one_pre, %lhs_nz) : (i1, i1) -> i1

    %sign_zero_mask = "transfer.select"(%sign_zero_known, %sign_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sign_one_mask = "transfer.select"(%sign_one_known, %sign_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_sign = "transfer.or"(%low_zero_mask, %sign_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_sign = "transfer.or"(%res1_tz, %sign_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_min_safe = "transfer.select"(%rhs1_is_zero, %const1, %rhs1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %max_quot_nonneg = "transfer.udiv"(%lhs_max, %rhs_min_safe) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %nonneg_leadz = "transfer.countl_zero"(%max_quot_nonneg) : (!transfer.integer) -> !transfer.integer
    %nonneg_leadz_inv = "transfer.sub"(%bitwidth, %nonneg_leadz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %high_zero_nonneg_cand = "transfer.shl"(%all_ones, %nonneg_leadz_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %high_zero_nonneg = "transfer.select"(%sign_zero_nn, %high_zero_nonneg_cand, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_sign_refined = "transfer.or"(%res0_sign, %high_zero_nonneg) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_minus_1 = "transfer.sub"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_and_minus_1 = "transfer.and"(%rhs1, %rhs1_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_and_minus_1_is_zero = "transfer.cmp"(%rhs1_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_nonzero = "transfer.cmp"(%rhs1, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_pow2 = "arith.andi"(%rhs1_and_minus_1_is_zero, %rhs1_nonzero) : (i1, i1) -> i1
    %rhs_pow2_pos = "arith.andi"(%rhs_is_pow2, %rhs_nonneg) : (i1, i1) -> i1
    %rhs_const_pow2_pos = "arith.andi"(%rhs_is_const, %rhs_pow2_pos) : (i1, i1) -> i1
    %rhs_shift = "transfer.countr_zero"(%rhs1) : (!transfer.integer) -> !transfer.integer
    %res0_pow2 = "transfer.ashr"(%lhs0, %rhs_shift) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_pow2 = "transfer.ashr"(%lhs1, %rhs_shift) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_precise = "transfer.select"(%rhs_const_pow2_pos, %res0_pow2, %res0_sign_refined) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_precise = "transfer.select"(%rhs_const_pow2_pos, %res1_pow2, %res1_sign) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1

    %not_const1 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs0_is_not1 = "transfer.cmp"(%rhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_1 = "transfer.cmp"(%rhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_one = "arith.andi"(%rhs0_is_not1, %rhs1_is_1) : (i1, i1) -> i1

    %res0_rhs_one = "transfer.select"(%rhs_is_one, %lhs0, %res0_precise) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_one = "transfer.select"(%rhs_is_one, %lhs1, %res1_precise) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%lhs_is_zero, %all_ones, %res0_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%lhs_is_zero, %const0, %res1_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_sdivexact", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
