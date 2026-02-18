"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %const2 = "transfer.constant"(%lhs0) {value = 2 : index} : (!transfer.integer) -> !transfer.integer
    %const_true = "arith.constant"() {value = 1 : i1} : () -> i1
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %lhs_min_tz = "transfer.countr_one"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_min_tz = "transfer.countr_one"(%rhs0) : (!transfer.integer) -> !transfer.integer
    %tz_sum = "transfer.add"(%lhs_min_tz, %rhs_min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %tz_sum_lt_bw = "transfer.cmp"(%tz_sum, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %tz_sum_clamped = "transfer.select"(%tz_sum_lt_bw, %tz_sum, %bitwidth) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %tz_sum_inv = "transfer.sub"(%bitwidth, %tz_sum_clamped) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_base = "transfer.lshr"(%all_ones, %tz_sum_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_lsb_one = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_lsb_one = "transfer.and"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_odd = "transfer.cmp"(%lhs_lsb_one, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_odd = "transfer.cmp"(%rhs_lsb_one, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_odd = "arith.andi"(%lhs_odd, %rhs_odd) : (i1, i1) -> i1
    %res1_base = "transfer.select"(%both_odd, %const1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    // If both operands are odd, bit1 of product is xor(bit1(lhs), bit1(rhs)).
    %lhs_bit1_zero = "transfer.and"(%lhs0, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_bit1_one = "transfer.and"(%lhs1, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_bit1_zero = "transfer.and"(%rhs0, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_bit1_one = "transfer.and"(%rhs1, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero_00 = "transfer.and"(%lhs_bit1_zero, %rhs_bit1_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero_11 = "transfer.and"(%lhs_bit1_one, %rhs_bit1_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero = "transfer.or"(%bit1_zero_00, %bit1_zero_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one_01 = "transfer.and"(%lhs_bit1_zero, %rhs_bit1_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one_10 = "transfer.and"(%lhs_bit1_one, %rhs_bit1_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one = "transfer.or"(%bit1_one_01, %bit1_one_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero_odd = "transfer.select"(%both_odd, %bit1_zero, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one_odd = "transfer.select"(%both_odd, %bit1_one, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_precise = "transfer.or"(%res0_base, %bit1_zero_odd) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_precise = "transfer.or"(%res1_base, %bit1_one_odd) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %not_const1 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs0_is_not1 = "transfer.cmp"(%rhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_1 = "transfer.cmp"(%rhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_one = "arith.andi"(%rhs0_is_not1, %rhs1_is_1) : (i1, i1) -> i1
    %res0_rhs_one = "transfer.select"(%rhs_is_one, %lhs0, %res0_precise) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_one = "transfer.select"(%rhs_is_one, %lhs1, %res1_precise) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_is_not1 = "transfer.cmp"(%lhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_1 = "transfer.cmp"(%lhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_one = "arith.andi"(%lhs0_is_not1, %lhs1_is_1) : (i1, i1) -> i1
    %res0_lhs_one = "transfer.select"(%lhs_is_one, %rhs0, %res0_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lhs_one = "transfer.select"(%lhs_is_one, %rhs1, %res1_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1
    %rhs0_all_ones = "transfer.cmp"(%rhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_zero = "arith.andi"(%rhs0_all_ones, %rhs1_is_zero) : (i1, i1) -> i1
    %either_is_zero = "arith.ori"(%lhs_is_zero, %rhs_is_zero) : (i1, i1) -> i1
    %mul0 = "transfer.select"(%either_is_zero, %all_ones, %res0_lhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mul1 = "transfer.select"(%either_is_zero, %const0, %res1_lhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_min_nonzero = "transfer.cmp"(%lhs1, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_min_nonzero = "transfer.cmp"(%rhs1, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %min_ov = "transfer.umul_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %min_nonzero = "arith.andi"(%lhs_min_nonzero, %rhs_min_nonzero) : (i1, i1) -> i1
    %always_overflow = "arith.andi"(%min_nonzero, %min_ov) : (i1, i1) -> i1
    %max_ov = "transfer.umul_overflow"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> i1
    %never_overflow = "arith.xori"(%max_ov, %const_true) : (i1, i1) -> i1

    %res0_partial = "transfer.select"(%never_overflow, %mul0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_sat = "transfer.select"(%always_overflow, %const0, %res0_partial) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_sat = "transfer.select"(%always_overflow, %all_ones, %mul1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1
    %const_mul = "transfer.mul"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_ov = "transfer.umul_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %const_val = "transfer.select"(%const_ov, %all_ones, %const_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_val_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // Enumerate one/two unknown bits when one side is constant.
    %lhs_known_union = "transfer.or"(%lhs0, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_mask = "transfer.xor"(%lhs_known_union, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_nonzero = "transfer.cmp"(%lhs_unknown_mask, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_unknown_minus_1 = "transfer.sub"(%lhs_unknown_mask, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_and_minus_1 = "transfer.and"(%lhs_unknown_mask, %lhs_unknown_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_pow2ish = "transfer.cmp"(%lhs_unknown_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_one_unknown = "arith.andi"(%lhs_unknown_nonzero, %lhs_unknown_pow2ish) : (i1, i1) -> i1
    %lhs_unknown_neg = "transfer.neg"(%lhs_unknown_mask) : (!transfer.integer) -> !transfer.integer
    %lhs_unknown_lowbit = "transfer.and"(%lhs_unknown_mask, %lhs_unknown_neg) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_unknown_rest = "transfer.xor"(%lhs_unknown_mask, %lhs_unknown_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rest_nonzero = "transfer.cmp"(%lhs_unknown_rest, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_rest_minus_1 = "transfer.sub"(%lhs_unknown_rest, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rest_and_minus_1 = "transfer.and"(%lhs_unknown_rest, %lhs_rest_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rest_pow2ish = "transfer.cmp"(%lhs_rest_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_two_unknown = "arith.andi"(%lhs_rest_nonzero, %lhs_rest_pow2ish) : (i1, i1) -> i1

    %rhs_known_union = "transfer.or"(%rhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_mask = "transfer.xor"(%rhs_known_union, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_nonzero = "transfer.cmp"(%rhs_unknown_mask, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_unknown_minus_1 = "transfer.sub"(%rhs_unknown_mask, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_and_minus_1 = "transfer.and"(%rhs_unknown_mask, %rhs_unknown_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_pow2ish = "transfer.cmp"(%rhs_unknown_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_one_unknown = "arith.andi"(%rhs_unknown_nonzero, %rhs_unknown_pow2ish) : (i1, i1) -> i1
    %lhs_rhs_one_one = "arith.andi"(%lhs_one_unknown, %rhs_one_unknown) : (i1, i1) -> i1
    %lhs_rhs_two_one = "arith.andi"(%lhs_two_unknown, %rhs_one_unknown) : (i1, i1) -> i1
    %rhs_unknown_neg = "transfer.neg"(%rhs_unknown_mask) : (!transfer.integer) -> !transfer.integer
    %rhs_unknown_lowbit = "transfer.and"(%rhs_unknown_mask, %rhs_unknown_neg) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_rest = "transfer.xor"(%rhs_unknown_mask, %rhs_unknown_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_rest_nonzero = "transfer.cmp"(%rhs_unknown_rest, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_rest_minus_1 = "transfer.sub"(%rhs_unknown_rest, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_rest_and_minus_1 = "transfer.and"(%rhs_unknown_rest, %rhs_rest_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_rest_pow2ish = "transfer.cmp"(%rhs_rest_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_two_unknown = "arith.andi"(%rhs_rest_nonzero, %rhs_rest_pow2ish) : (i1, i1) -> i1
    %lhs_rhs_one_two = "arith.andi"(%lhs_one_unknown, %rhs_two_unknown) : (i1, i1) -> i1

    // lhs const, rhs one unknown.
    %lhs_const_rhs_one_unknown = "arith.andi"(%lhs_is_const, %rhs_one_unknown) : (i1, i1) -> i1
    %rhs_alt = "transfer.add"(%rhs1, %rhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g_val1_mul = "transfer.mul"(%lhs1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g_val1_ov = "transfer.umul_overflow"(%lhs1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %g_val1 = "transfer.select"(%g_val1_ov, %all_ones, %g_val1_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %g_val0_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g_val1_not = "transfer.xor"(%g_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g0_raw = "transfer.and"(%g_val0_not, %g_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g1_raw = "transfer.and"(%const_val, %g_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %g0 = "transfer.select"(%lhs_const_rhs_one_unknown, %g0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %g1 = "transfer.select"(%lhs_const_rhs_one_unknown, %g1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // lhs const, rhs two unknown.
    %lhs_const_rhs_two_unknown = "arith.andi"(%lhs_is_const, %rhs_two_unknown) : (i1, i1) -> i1
    %rhs_alt1 = "transfer.add"(%rhs1, %rhs_unknown_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_alt2 = "transfer.add"(%rhs1, %rhs_unknown_rest) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_alt3 = "transfer.add"(%rhs1, %rhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val1_mul = "transfer.mul"(%lhs1, %rhs_alt1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val1_ov = "transfer.umul_overflow"(%lhs1, %rhs_alt1) : (!transfer.integer, !transfer.integer) -> i1
    %h_val1 = "transfer.select"(%h_val1_ov, %all_ones, %h_val1_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val2_mul = "transfer.mul"(%lhs1, %rhs_alt2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val2_ov = "transfer.umul_overflow"(%lhs1, %rhs_alt2) : (!transfer.integer, !transfer.integer) -> i1
    %h_val2 = "transfer.select"(%h_val2_ov, %all_ones, %h_val2_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val3_mul = "transfer.mul"(%lhs1, %rhs_alt3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val3_ov = "transfer.umul_overflow"(%lhs1, %rhs_alt3) : (!transfer.integer, !transfer.integer) -> i1
    %h_val3 = "transfer.select"(%h_val3_ov, %all_ones, %h_val3_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val0_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val1_not = "transfer.xor"(%h_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val2_not = "transfer.xor"(%h_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h_val3_not = "transfer.xor"(%h_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h0_01 = "transfer.and"(%h_val0_not, %h_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h0_23 = "transfer.and"(%h_val2_not, %h_val3_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h0_raw = "transfer.and"(%h0_01, %h0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h1_01 = "transfer.and"(%const_val, %h_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h1_23 = "transfer.and"(%h_val2, %h_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h1_raw = "transfer.and"(%h1_01, %h1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %h0 = "transfer.select"(%lhs_const_rhs_two_unknown, %h0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %h1 = "transfer.select"(%lhs_const_rhs_two_unknown, %h1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // rhs const, lhs one unknown.
    %rhs_const_lhs_one_unknown = "arith.andi"(%rhs_is_const, %lhs_one_unknown) : (i1, i1) -> i1
    %lhs_alt = "transfer.add"(%lhs1, %lhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i_val1_mul = "transfer.mul"(%lhs_alt, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i_val1_ov = "transfer.umul_overflow"(%lhs_alt, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %i_val1 = "transfer.select"(%i_val1_ov, %all_ones, %i_val1_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %i_val0_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i_val1_not = "transfer.xor"(%i_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i0_raw = "transfer.and"(%i_val0_not, %i_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i1_raw = "transfer.and"(%const_val, %i_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %i0 = "transfer.select"(%rhs_const_lhs_one_unknown, %i0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %i1 = "transfer.select"(%rhs_const_lhs_one_unknown, %i1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // rhs const, lhs two unknown.
    %rhs_const_lhs_two_unknown = "arith.andi"(%rhs_is_const, %lhs_two_unknown) : (i1, i1) -> i1
    %lhs_alt1 = "transfer.add"(%lhs1, %lhs_unknown_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_alt2 = "transfer.add"(%lhs1, %lhs_unknown_rest) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_alt3 = "transfer.add"(%lhs1, %lhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val1_mul = "transfer.mul"(%lhs_alt1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val1_ov = "transfer.umul_overflow"(%lhs_alt1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %j_val1 = "transfer.select"(%j_val1_ov, %all_ones, %j_val1_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val2_mul = "transfer.mul"(%lhs_alt2, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val2_ov = "transfer.umul_overflow"(%lhs_alt2, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %j_val2 = "transfer.select"(%j_val2_ov, %all_ones, %j_val2_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val3_mul = "transfer.mul"(%lhs_alt3, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val3_ov = "transfer.umul_overflow"(%lhs_alt3, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %j_val3 = "transfer.select"(%j_val3_ov, %all_ones, %j_val3_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val0_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val1_not = "transfer.xor"(%j_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val2_not = "transfer.xor"(%j_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j_val3_not = "transfer.xor"(%j_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j0_01 = "transfer.and"(%j_val0_not, %j_val1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j0_23 = "transfer.and"(%j_val2_not, %j_val3_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j0_raw = "transfer.and"(%j0_01, %j0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j1_01 = "transfer.and"(%const_val, %j_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j1_23 = "transfer.and"(%j_val2, %j_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j1_raw = "transfer.and"(%j1_01, %j1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %j0 = "transfer.select"(%rhs_const_lhs_two_unknown, %j0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %j1 = "transfer.select"(%rhs_const_lhs_two_unknown, %j1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // lhs one unknown, rhs two unknown.
    %p11_mul = "transfer.mul"(%lhs_alt, %rhs_alt1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p11_ov = "transfer.umul_overflow"(%lhs_alt, %rhs_alt1) : (!transfer.integer, !transfer.integer) -> i1
    %p11 = "transfer.select"(%p11_ov, %all_ones, %p11_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %p12_mul = "transfer.mul"(%lhs_alt, %rhs_alt2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p12_ov = "transfer.umul_overflow"(%lhs_alt, %rhs_alt2) : (!transfer.integer, !transfer.integer) -> i1
    %p12 = "transfer.select"(%p12_ov, %all_ones, %p12_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %p13_mul = "transfer.mul"(%lhs_alt, %rhs_alt3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p13_ov = "transfer.umul_overflow"(%lhs_alt, %rhs_alt3) : (!transfer.integer, !transfer.integer) -> i1
    %p13 = "transfer.select"(%p13_ov, %all_ones, %p13_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %p00_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p01_not = "transfer.xor"(%h_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p02_not = "transfer.xor"(%h_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p03_not = "transfer.xor"(%h_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p10_not = "transfer.xor"(%i_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p11_not = "transfer.xor"(%p11, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p12_not = "transfer.xor"(%p12, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p13_not = "transfer.xor"(%p13, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_01 = "transfer.and"(%p00_not, %p01_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_23 = "transfer.and"(%p02_not, %p03_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_45 = "transfer.and"(%p10_not, %p11_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_67 = "transfer.and"(%p12_not, %p13_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_0123 = "transfer.and"(%p0_01, %p0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_4567 = "transfer.and"(%p0_45, %p0_67) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0_raw = "transfer.and"(%p0_0123, %p0_4567) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_01 = "transfer.and"(%const_val, %h_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_23 = "transfer.and"(%h_val2, %h_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_45 = "transfer.and"(%i_val1, %p11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_67 = "transfer.and"(%p12, %p13) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_0123 = "transfer.and"(%p1_01, %p1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_4567 = "transfer.and"(%p1_45, %p1_67) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p1_raw = "transfer.and"(%p1_0123, %p1_4567) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %p0 = "transfer.select"(%lhs_rhs_one_two, %p0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %p1 = "transfer.select"(%lhs_rhs_one_two, %p1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // lhs two unknown, rhs one unknown.
    %q11_mul = "transfer.mul"(%lhs_alt1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q11_ov = "transfer.umul_overflow"(%lhs_alt1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %q11 = "transfer.select"(%q11_ov, %all_ones, %q11_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %q12_mul = "transfer.mul"(%lhs_alt2, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q12_ov = "transfer.umul_overflow"(%lhs_alt2, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %q12 = "transfer.select"(%q12_ov, %all_ones, %q12_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %q13_mul = "transfer.mul"(%lhs_alt3, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q13_ov = "transfer.umul_overflow"(%lhs_alt3, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %q13 = "transfer.select"(%q13_ov, %all_ones, %q13_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %q00_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q01_not = "transfer.xor"(%g_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q02_not = "transfer.xor"(%j_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q03_not = "transfer.xor"(%j_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q04_not = "transfer.xor"(%j_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q05_not = "transfer.xor"(%q11, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q06_not = "transfer.xor"(%q12, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q07_not = "transfer.xor"(%q13, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_01 = "transfer.and"(%q00_not, %q01_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_23 = "transfer.and"(%q02_not, %q03_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_45 = "transfer.and"(%q04_not, %q05_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_67 = "transfer.and"(%q06_not, %q07_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_0123 = "transfer.and"(%q0_01, %q0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_4567 = "transfer.and"(%q0_45, %q0_67) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0_raw = "transfer.and"(%q0_0123, %q0_4567) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_01 = "transfer.and"(%const_val, %g_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_23 = "transfer.and"(%j_val1, %j_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_45 = "transfer.and"(%j_val3, %q11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_67 = "transfer.and"(%q12, %q13) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_0123 = "transfer.and"(%q1_01, %q1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_4567 = "transfer.and"(%q1_45, %q1_67) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q1_raw = "transfer.and"(%q1_0123, %q1_4567) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %q0 = "transfer.select"(%lhs_rhs_two_one, %q0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %q1 = "transfer.select"(%lhs_rhs_two_one, %q1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // lhs one unknown, rhs one unknown.
    %n_val11_mul = "transfer.mul"(%lhs_alt, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_val11_ov = "transfer.umul_overflow"(%lhs_alt, %rhs_alt) : (!transfer.integer, !transfer.integer) -> i1
    %n_val11 = "transfer.select"(%n_val11_ov, %all_ones, %n_val11_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %n_val00_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_val01_not = "transfer.xor"(%g_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_val10_not = "transfer.xor"(%i_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_val11_not = "transfer.xor"(%n_val11, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0_01 = "transfer.and"(%n_val00_not, %n_val01_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0_23 = "transfer.and"(%n_val10_not, %n_val11_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0_raw = "transfer.and"(%n0_01, %n0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n1_01 = "transfer.and"(%const_val, %g_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n1_23 = "transfer.and"(%i_val1, %n_val11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n1_raw = "transfer.and"(%n1_01, %n1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n0 = "transfer.select"(%lhs_rhs_one_one, %n0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %n1 = "transfer.select"(%lhs_rhs_one_one, %n1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_g = "transfer.or"(%res0_sat, %g0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_h = "transfer.or"(%res0_g, %h0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_i = "transfer.or"(%res0_h, %i0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_j = "transfer.or"(%res0_i, %j0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_p = "transfer.or"(%res0_j, %p0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_q = "transfer.or"(%res0_p, %q0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_n = "transfer.or"(%res0_q, %n0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_g = "transfer.or"(%res1_sat, %g1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_h = "transfer.or"(%res1_g, %h1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_i = "transfer.or"(%res1_h, %i1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_j = "transfer.or"(%res1_i, %j1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_p = "transfer.or"(%res1_j, %p1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_q = "transfer.or"(%res1_p, %q1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_n = "transfer.or"(%res1_q, %n1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.select"(%both_const, %const_val_not, %res0_n) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_val, %res1_n) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_umulsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
