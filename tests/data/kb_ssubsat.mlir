"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %const_true = "arith.constant"() {value = 1 : i1} : () -> i1
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %signed_max = "transfer.get_signed_max_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %signed_min = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1

    %rhs0_all_ones = "transfer.cmp"(%rhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_zero = "arith.andi"(%rhs0_all_ones, %rhs1_is_zero) : (i1, i1) -> i1
    %id_res0 = "transfer.select"(%rhs_is_zero, %lhs0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1 = "transfer.select"(%rhs_is_zero, %lhs1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_known_union = "transfer.or"(%lhs0, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_mask = "transfer.xor"(%lhs_known_union, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_nonzero = "transfer.cmp"(%lhs_unknown_mask, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_unknown_minus_1 = "transfer.sub"(%lhs_unknown_mask, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_and_minus_1 = "transfer.and"(%lhs_unknown_mask, %lhs_unknown_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_pow2ish = "transfer.cmp"(%lhs_unknown_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_one_unknown = "arith.andi"(%lhs_unknown_nonzero, %lhs_unknown_pow2ish) : (i1, i1) -> i1
    %rhs_known_union = "transfer.or"(%rhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_mask = "transfer.xor"(%rhs_known_union, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_nonzero = "transfer.cmp"(%rhs_unknown_mask, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_unknown_minus_1 = "transfer.sub"(%rhs_unknown_mask, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_and_minus_1 = "transfer.and"(%rhs_unknown_mask, %rhs_unknown_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_pow2ish = "transfer.cmp"(%rhs_unknown_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_one_unknown = "arith.andi"(%rhs_unknown_nonzero, %rhs_unknown_pow2ish) : (i1, i1) -> i1
    %lhs_const_rhs_one_unknown = "arith.andi"(%lhs_is_const, %rhs_one_unknown) : (i1, i1) -> i1
    %rhs_const_lhs_one_unknown = "arith.andi"(%rhs_is_const, %lhs_one_unknown) : (i1, i1) -> i1
    %lhs_rhs_one_one = "arith.andi"(%lhs_one_unknown, %rhs_one_unknown) : (i1, i1) -> i1

    %lhs_sign_zero_bits = "transfer.and"(%lhs0, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_zero_bits = "transfer.and"(%rhs0, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_sign_one_bits = "transfer.and"(%lhs1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_one_bits = "transfer.and"(%rhs1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_nonneg = "transfer.cmp"(%lhs_sign_zero_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_nonneg = "transfer.cmp"(%rhs_sign_zero_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_neg = "transfer.cmp"(%lhs_sign_one_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_neg = "transfer.cmp"(%rhs_sign_one_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_nonneg = "arith.andi"(%lhs_nonneg, %rhs_nonneg) : (i1, i1) -> i1
    %both_neg = "arith.andi"(%lhs_neg, %rhs_neg) : (i1, i1) -> i1
    %mixed_pos = "arith.andi"(%lhs_nonneg, %rhs_neg) : (i1, i1) -> i1
    %mixed_neg = "arith.andi"(%lhs_neg, %rhs_nonneg) : (i1, i1) -> i1
    %same_sign = "arith.ori"(%both_nonneg, %both_neg) : (i1, i1) -> i1

    // Class-refined signed extrema for mixed-sign subtraction.
    %lhs_nonneg_min = "transfer.and"(%lhs1, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_nonneg_max = "transfer.and"(%lhs_max, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_nonneg_min = "transfer.and"(%rhs1, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_nonneg_max = "transfer.and"(%rhs_max, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_neg_min = "transfer.or"(%lhs1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_neg_max = "transfer.or"(%lhs_nonneg_max, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_neg_min = "transfer.or"(%rhs1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_neg_max = "transfer.or"(%rhs_nonneg_max, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %ov_pos_min = "transfer.ssub_overflow"(%lhs_nonneg_min, %rhs_neg_max) : (!transfer.integer, !transfer.integer) -> i1
    %ov_pos_max = "transfer.ssub_overflow"(%lhs_nonneg_max, %rhs_neg_min) : (!transfer.integer, !transfer.integer) -> i1
    %ov_neg_min = "transfer.ssub_overflow"(%lhs_neg_min, %rhs_nonneg_max) : (!transfer.integer, !transfer.integer) -> i1
    %ov_neg_max = "transfer.ssub_overflow"(%lhs_neg_max, %rhs_nonneg_min) : (!transfer.integer, !transfer.integer) -> i1
    %not_ov_pos_max = "arith.xori"(%ov_pos_max, %const_true) : (i1, i1) -> i1
    %not_ov_neg_min = "arith.xori"(%ov_neg_min, %const_true) : (i1, i1) -> i1
    %must_pos = "arith.andi"(%mixed_pos, %ov_pos_min) : (i1, i1) -> i1
    %never_pos = "arith.andi"(%mixed_pos, %not_ov_pos_max) : (i1, i1) -> i1
    %must_neg = "arith.andi"(%mixed_neg, %ov_neg_max) : (i1, i1) -> i1
    %never_neg = "arith.andi"(%mixed_neg, %not_ov_neg_min) : (i1, i1) -> i1
    %not_must_pos = "arith.xori"(%must_pos, %const_true) : (i1, i1) -> i1
    %not_never_pos = "arith.xori"(%never_pos, %const_true) : (i1, i1) -> i1
    %maybe_pos0 = "arith.andi"(%mixed_pos, %not_must_pos) : (i1, i1) -> i1
    %maybe_pos = "arith.andi"(%maybe_pos0, %not_never_pos) : (i1, i1) -> i1
    %not_must_neg = "arith.xori"(%must_neg, %const_true) : (i1, i1) -> i1
    %not_never_neg = "arith.xori"(%never_neg, %const_true) : (i1, i1) -> i1
    %maybe_neg0 = "arith.andi"(%mixed_neg, %not_must_neg) : (i1, i1) -> i1
    %maybe_neg = "arith.andi"(%maybe_neg0, %not_never_neg) : (i1, i1) -> i1
    %no_ov_known_a = "arith.ori"(%same_sign, %never_pos) : (i1, i1) -> i1
    %no_ov_known = "arith.ori"(%no_ov_known_a, %never_neg) : (i1, i1) -> i1

    // KnownBits transfer for wrapping subtraction: lhs + (~rhs + 1).
    %const1_not = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_a_max = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_b_max = "transfer.xor"(%const1_not, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_sum_min = "transfer.add"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_sum_max = "transfer.add"(%neg_rhs_a_max, %neg_rhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_min_and = "transfer.and"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_min_or = "transfer.or"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_sum_min_not = "transfer.xor"(%neg_rhs_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_min_or_and_sum_not = "transfer.and"(%neg_rhs_min_or, %neg_rhs_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_carry_out_min = "transfer.or"(%neg_rhs_min_and, %neg_rhs_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_max_and = "transfer.and"(%neg_rhs_a_max, %neg_rhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_max_or = "transfer.or"(%neg_rhs_a_max, %neg_rhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_sum_max_not = "transfer.xor"(%neg_rhs_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_max_or_and_sum_not = "transfer.and"(%neg_rhs_max_or, %neg_rhs_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_carry_out_max = "transfer.or"(%neg_rhs_max_and, %neg_rhs_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_carry_one = "transfer.shl"(%neg_rhs_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_carry_may_one = "transfer.shl"(%neg_rhs_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_carry_zero = "transfer.xor"(%neg_rhs_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor0_ab_00 = "transfer.and"(%rhs1, %const1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor0_ab_11 = "transfer.and"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor1_ab_01 = "transfer.and"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor1_ab_10 = "transfer.and"(%rhs0, %const1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor_ab_0 = "transfer.or"(%neg_rhs_xor0_ab_00, %neg_rhs_xor0_ab_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor_ab_1 = "transfer.or"(%neg_rhs_xor1_ab_01, %neg_rhs_xor1_ab_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor0_sum_carry_00 = "transfer.and"(%neg_rhs_xor_ab_0, %neg_rhs_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor0_sum_carry_11 = "transfer.and"(%neg_rhs_xor_ab_1, %neg_rhs_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor1_sum_carry_01 = "transfer.and"(%neg_rhs_xor_ab_0, %neg_rhs_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_rhs_xor1_sum_carry_10 = "transfer.and"(%neg_rhs_xor_ab_1, %neg_rhs_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_neg0 = "transfer.or"(%neg_rhs_xor0_sum_carry_00, %neg_rhs_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_neg1 = "transfer.or"(%neg_rhs_xor1_sum_carry_01, %neg_rhs_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sub_a_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_b_max = "transfer.xor"(%rhs_neg0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_sum_min = "transfer.add"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_sum_max = "transfer.add"(%sub_a_max, %sub_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_min_and = "transfer.and"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_min_or = "transfer.or"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_sum_min_not = "transfer.xor"(%sub_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_min_or_and_sum_not = "transfer.and"(%sub_min_or, %sub_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_carry_out_min = "transfer.or"(%sub_min_and, %sub_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_max_and = "transfer.and"(%sub_a_max, %sub_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_max_or = "transfer.or"(%sub_a_max, %sub_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_sum_max_not = "transfer.xor"(%sub_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_max_or_and_sum_not = "transfer.and"(%sub_max_or, %sub_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_carry_out_max = "transfer.or"(%sub_max_and, %sub_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_carry_one = "transfer.shl"(%sub_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_carry_may_one = "transfer.shl"(%sub_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_carry_zero = "transfer.xor"(%sub_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor0_ab_00 = "transfer.and"(%lhs0, %rhs_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor0_ab_11 = "transfer.and"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor1_ab_01 = "transfer.and"(%lhs0, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor1_ab_10 = "transfer.and"(%lhs1, %rhs_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor_ab_0 = "transfer.or"(%sub_xor0_ab_00, %sub_xor0_ab_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor_ab_1 = "transfer.or"(%sub_xor1_ab_01, %sub_xor1_ab_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor0_sum_carry_00 = "transfer.and"(%sub_xor_ab_0, %sub_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor0_sum_carry_11 = "transfer.and"(%sub_xor_ab_1, %sub_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor1_sum_carry_01 = "transfer.and"(%sub_xor_ab_0, %sub_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_xor1_sum_carry_10 = "transfer.and"(%sub_xor_ab_1, %sub_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub0 = "transfer.or"(%sub_xor0_sum_carry_00, %sub_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub1 = "transfer.or"(%sub_xor1_sum_carry_01, %sub_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sub0_exact = "transfer.select"(%no_ov_known, %sub0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sub1_exact = "transfer.select"(%no_ov_known, %sub1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_pos0 = "transfer.select"(%must_pos, %signed_min, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_pos1 = "transfer.select"(%must_pos, %signed_max, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_neg0 = "transfer.select"(%must_neg, %signed_max, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_neg1 = "transfer.select"(%must_neg, %signed_min, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_pos0_raw = "transfer.and"(%sub0, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_pos1_raw = "transfer.and"(%sub1, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg0_raw = "transfer.and"(%sub0, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg1_raw = "transfer.and"(%sub1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_pos0 = "transfer.select"(%maybe_pos, %mix_pos0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_pos1 = "transfer.select"(%maybe_pos, %mix_pos1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg0 = "transfer.select"(%maybe_neg, %mix_neg0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg1 = "transfer.select"(%maybe_neg, %mix_neg1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // One-unknown-bit enumeration for constant/near-constant cases.
    %e00_sub = "transfer.sub"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %e00_ov = "transfer.ssub_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_neg = "transfer.cmp"(%lhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %e00_sat = "transfer.select"(%lhs1_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %e00 = "transfer.select"(%e00_ov, %e00_sat, %e00_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %e00_not = "transfer.xor"(%e00, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_alt = "transfer.add"(%rhs1, %rhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g_sub = "transfer.sub"(%lhs1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g_ov = "transfer.ssub_overflow"(%lhs1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %g_val1 = "transfer.select"(%g_ov, %e00_sat, %g_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %g_val1_not = "transfer.xor"(%g_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g0_raw = "transfer.and"(%e00_not, %g_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g1_raw = "transfer.and"(%e00, %g_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g0 = "transfer.select"(%lhs_const_rhs_one_unknown, %g0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %g1 = "transfer.select"(%lhs_const_rhs_one_unknown, %g1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_alt = "transfer.add"(%lhs1, %lhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_alt_neg = "transfer.cmp"(%lhs_alt, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %i_sat = "transfer.select"(%lhs_alt_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %i_sub = "transfer.sub"(%lhs_alt, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i_ov = "transfer.ssub_overflow"(%lhs_alt, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %i_val1 = "transfer.select"(%i_ov, %i_sat, %i_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %i_val1_not = "transfer.xor"(%i_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i0_raw = "transfer.and"(%e00_not, %i_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i1_raw = "transfer.and"(%e00, %i_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i0 = "transfer.select"(%rhs_const_lhs_one_unknown, %i0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %i1 = "transfer.select"(%rhs_const_lhs_one_unknown, %i1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %n_sub = "transfer.sub"(%lhs_alt, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_ov = "transfer.ssub_overflow"(%lhs_alt, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %n_val11 = "transfer.select"(%n_ov, %i_sat, %n_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %n_val11_not = "transfer.xor"(%n_val11, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0_01 = "transfer.and"(%e00_not, %g_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0_23 = "transfer.and"(%i_val1_not, %n_val11_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0_raw = "transfer.and"(%n0_01, %n0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n1_01 = "transfer.and"(%e00, %g_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n1_23 = "transfer.and"(%i_val1, %n_val11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n1_raw = "transfer.and"(%n1_01, %n1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0 = "transfer.select"(%lhs_rhs_one_one, %n0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %n1 = "transfer.select"(%lhs_rhs_one_one, %n1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // Signed endpoint refinement: [sat_sub(smin(lhs), smax(rhs)), sat_sub(smax(lhs), smin(rhs))].
    %lhs_sign_can_be_one = "transfer.and"(%lhs_max, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_can_be_one = "transfer.and"(%rhs_max, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_smin = "transfer.or"(%lhs1, %lhs_sign_can_be_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_smin = "transfer.or"(%rhs1, %rhs_sign_can_be_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_upper_max = "transfer.and"(%lhs_max, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_upper_max = "transfer.and"(%rhs_max, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_smax = "transfer.or"(%lhs_upper_max, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_smax = "transfer.or"(%rhs_upper_max, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range_min_sub = "transfer.sub"(%lhs_smin, %rhs_smax) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range_min_ov = "transfer.ssub_overflow"(%lhs_smin, %rhs_smax) : (!transfer.integer, !transfer.integer) -> i1
    %lhs_smin_neg = "transfer.cmp"(%lhs_smin, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %range_min_sat = "transfer.select"(%lhs_smin_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %range_min_val = "transfer.select"(%range_min_ov, %range_min_sat, %range_min_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %range_max_sub = "transfer.sub"(%lhs_smax, %rhs_smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range_max_ov = "transfer.ssub_overflow"(%lhs_smax, %rhs_smin) : (!transfer.integer, !transfer.integer) -> i1
    %lhs_smax_neg = "transfer.cmp"(%lhs_smax, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %range_max_sat = "transfer.select"(%lhs_smax_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %range_max_val = "transfer.select"(%range_max_ov, %range_max_sat, %range_max_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %range_diff = "transfer.xor"(%range_min_val, %range_max_val) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %common_lz = "transfer.countl_zero"(%range_diff) : (!transfer.integer) -> !transfer.integer
    %common_inv = "transfer.sub"(%bitwidth, %common_lz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %common_mask = "transfer.shl"(%all_ones, %common_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range_min_not = "transfer.xor"(%range_min_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range0 = "transfer.and"(%range_min_not, %common_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range1 = "transfer.and"(%range_min_val, %common_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range_min_nonneg = "transfer.cmp"(%range_min_val, %const0) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %range_max_neg = "transfer.cmp"(%range_max_val, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %range_sign0 = "transfer.select"(%range_min_nonneg, %signed_min, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %range_sign1 = "transfer.select"(%range_max_neg, %signed_min, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %range0_ext = "transfer.or"(%range0, %range_sign0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range1_ext = "transfer.or"(%range1, %range_sign1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // Mixed-sign class-local endpoint refinement.
    %pos_min_sub = "transfer.sub"(%lhs_nonneg_min, %rhs_neg_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_min_val = "transfer.select"(%ov_pos_min, %signed_max, %pos_min_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_max_sub = "transfer.sub"(%lhs_nonneg_max, %rhs_neg_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_max_val = "transfer.select"(%ov_pos_max, %signed_max, %pos_max_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_diff = "transfer.xor"(%pos_min_val, %pos_max_val) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_lz = "transfer.countl_zero"(%pos_diff) : (!transfer.integer) -> !transfer.integer
    %pos_inv = "transfer.sub"(%bitwidth, %pos_lz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_mask = "transfer.shl"(%all_ones, %pos_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos_min_not = "transfer.xor"(%pos_min_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos0_raw = "transfer.and"(%pos_min_not, %pos_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos1_raw = "transfer.and"(%pos_min_val, %pos_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %pos0 = "transfer.select"(%mixed_pos, %pos0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %pos1 = "transfer.select"(%mixed_pos, %pos1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %neg_min_sub = "transfer.sub"(%lhs_neg_min, %rhs_nonneg_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_min_val = "transfer.select"(%ov_neg_min, %signed_min, %neg_min_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_max_sub = "transfer.sub"(%lhs_neg_max, %rhs_nonneg_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_max_val = "transfer.select"(%ov_neg_max, %signed_min, %neg_max_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_diff = "transfer.xor"(%neg_min_val, %neg_max_val) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_lz = "transfer.countl_zero"(%neg_diff) : (!transfer.integer) -> !transfer.integer
    %neg_inv = "transfer.sub"(%bitwidth, %neg_lz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_mask = "transfer.shl"(%all_ones, %neg_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg_min_not = "transfer.xor"(%neg_min_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg0_raw = "transfer.and"(%neg_min_not, %neg_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg1_raw = "transfer.and"(%neg_min_val, %neg_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg0 = "transfer.select"(%mixed_neg, %neg0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %neg1 = "transfer.select"(%mixed_neg, %neg1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %base00 = "transfer.or"(%id_res0, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base01 = "transfer.or"(%base00, %sub0_exact) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base02 = "transfer.or"(%base01, %sat_pos0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base03 = "transfer.or"(%base02, %sat_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base04 = "transfer.or"(%base03, %mix_pos0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base05 = "transfer.or"(%base04, %mix_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base06 = "transfer.or"(%base05, %g0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base07 = "transfer.or"(%base06, %i0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base08 = "transfer.or"(%base07, %n0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base09 = "transfer.or"(%base08, %range0_ext) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base010 = "transfer.or"(%base09, %pos0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base0 = "transfer.or"(%base010, %neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base10 = "transfer.or"(%id_res1, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base11 = "transfer.or"(%base10, %sub1_exact) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base12 = "transfer.or"(%base11, %sat_pos1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base13 = "transfer.or"(%base12, %sat_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base14 = "transfer.or"(%base13, %mix_pos1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base15 = "transfer.or"(%base14, %mix_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base16 = "transfer.or"(%base15, %g1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base17 = "transfer.or"(%base16, %i1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base18 = "transfer.or"(%base17, %n1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base19 = "transfer.or"(%base18, %range1_ext) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base110 = "transfer.or"(%base19, %pos1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base1 = "transfer.or"(%base110, %neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %const_sub = "transfer.sub"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_ov = "transfer.ssub_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %lhs_const_neg = "transfer.cmp"(%lhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const_sat = "transfer.select"(%lhs_const_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1 = "transfer.select"(%const_ov, %const_sat, %const_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_res0, %base0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_res1, %base1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_ssubsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
