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
    %bw_minus_1 = "transfer.sub"(%bitwidth, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sign_mask = "transfer.shl"(%const1, %bw_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_tz = "transfer.countr_one"(%rhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_tz_inv = "transfer.sub"(%bitwidth, %rhs_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_mask = "transfer.lshr"(%all_ones, %rhs_tz_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_low = "transfer.and"(%lhs0, %low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_low = "transfer.and"(%lhs1, %low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_sign_zero = "transfer.and"(%lhs0, %sign_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_non_neg = "transfer.cmp"(%lhs_sign_zero, %sign_mask) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %lhs_mlz = "transfer.countl_one"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_mlz = "transfer.countl_one"(%rhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_mlo = "transfer.countl_one"(%rhs1) : (!transfer.integer) -> !transfer.integer
    %rhs_sign_zero = "transfer.and"(%rhs0, %sign_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_one = "transfer.and"(%rhs1, %sign_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_non_neg = "transfer.cmp"(%rhs_sign_zero, %sign_mask) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_neg = "transfer.cmp"(%rhs_sign_one, %sign_mask) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_sign_bits_or1 = "transfer.select"(%rhs_neg, %rhs_mlo, %const1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_min_sign_bits = "transfer.select"(%rhs_non_neg, %rhs_mlz, %rhs_sign_bits_or1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %leaders = "transfer.umax"(%lhs_mlz, %rhs_min_sign_bits) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %leaders_inv = "transfer.sub"(%bitwidth, %leaders) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %high_zero_mask = "transfer.shl"(%all_ones, %leaders_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %non_neg_zero_mask = "transfer.select"(%lhs_non_neg, %high_zero_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_mlo = "transfer.countl_one"(%lhs1) : (!transfer.integer) -> !transfer.integer
    %lhs_sign_one = "transfer.and"(%lhs1, %sign_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_neg = "transfer.cmp"(%lhs_sign_one, %sign_mask) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %res_low_nonzero = "transfer.cmp"(%res1_low, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_neg_nonzero = "arith.andi"(%lhs_neg, %res_low_nonzero) : (i1, i1) -> i1
    %leaders_neg = "transfer.umax"(%lhs_mlo, %rhs_min_sign_bits) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %leaders_neg_inv = "transfer.sub"(%bitwidth, %leaders_neg) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %high_one_mask = "transfer.shl"(%all_ones, %leaders_neg_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_one_mask = "transfer.select"(%lhs_neg_nonzero, %high_one_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_minus1 = "transfer.sub"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_and_minus1 = "transfer.and"(%rhs1, %rhs1_minus1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_and_minus1_is_zero = "transfer.cmp"(%rhs1_and_minus1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const_true = "arith.constant"() {value = 1 : i1} : () -> i1
    %rhs1_nonzero = "arith.xori"(%rhs1_is_zero, %const_true) : (i1, i1) -> i1
    %rhs_is_pow2 = "arith.andi"(%rhs1_and_minus1_is_zero, %rhs1_nonzero) : (i1, i1) -> i1
    %rhs_const_pow2 = "arith.andi"(%rhs_is_const, %rhs_is_pow2) : (i1, i1) -> i1
    %pow2_lowbits = "transfer.sub"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_upper_mask = "transfer.xor"(%pow2_lowbits, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_lowbits_not_in_lhs_zero = "transfer.and"(%pow2_lowbits, %lhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_lowbits_subset_lhs_zero = "transfer.cmp"(%pow2_lowbits_not_in_lhs_zero, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %pow2_zero_cond = "arith.ori"(%lhs_non_neg, %pow2_lowbits_subset_lhs_zero) : (i1, i1) -> i1
    %pow2_lowbits_hits_lhs_one = "transfer.and"(%pow2_lowbits, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_lowbits_hits_lhs_one_nonzero = "transfer.cmp"(%pow2_lowbits_hits_lhs_one, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %pow2_one_cond = "arith.andi"(%lhs_neg, %pow2_lowbits_hits_lhs_one_nonzero) : (i1, i1) -> i1
    %pow2_zero_gate = "arith.andi"(%rhs_const_pow2, %pow2_zero_cond) : (i1, i1) -> i1
    %pow2_one_gate = "arith.andi"(%rhs_const_pow2, %pow2_one_cond) : (i1, i1) -> i1
    %pow2_zero_mask = "transfer.select"(%pow2_zero_gate, %pow2_upper_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %pow2_one_mask = "transfer.select"(%pow2_one_gate, %pow2_upper_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_nonneg = "transfer.or"(%res0_low, %non_neg_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_nonneg = "transfer.or"(%res1_low, %neg_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_pow2 = "transfer.or"(%res0_nonneg, %pow2_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_pow2 = "transfer.or"(%res1_nonneg, %pow2_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1
    %res0_lhs_zero = "transfer.select"(%lhs_is_zero, %all_ones, %res0_pow2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lhs_zero = "transfer.select"(%lhs_is_zero, %const0, %res1_pow2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %not_const1 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs0_is_not1 = "transfer.cmp"(%rhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_1 = "transfer.cmp"(%rhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_pos1 = "arith.andi"(%rhs0_is_not1, %rhs1_is_1) : (i1, i1) -> i1

    %rhs0_is_0 = "transfer.cmp"(%rhs0, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_all_ones = "transfer.cmp"(%rhs1, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_neg1 = "arith.andi"(%rhs0_is_0, %rhs1_is_all_ones) : (i1, i1) -> i1

    %rhs_is_pm1 = "arith.ori"(%rhs_is_pos1, %rhs_is_neg1) : (i1, i1) -> i1
    %res0 = "transfer.select"(%rhs_is_pm1, %all_ones, %res0_lhs_zero) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%rhs_is_pm1, %const0, %res1_lhs_zero) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_mods", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
