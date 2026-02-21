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
    %const_false = "arith.constant"() {value = 0 : i1} : () -> i1
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %lhs_conflict = "transfer.and"(%lhs0, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_conflict = "transfer.and"(%rhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_consistent = "transfer.cmp"(%lhs_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_consistent = "transfer.cmp"(%rhs_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_min_le_bw = "transfer.cmp"(%rhs1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_lz_ub = "transfer.countl_zero"(%lhs1) : (!transfer.integer) -> !transfer.integer
    %lhs_lo_ub = "transfer.countl_zero"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %lhs_nonneg_possible = "arith.andi"(%const_true, %const_true) : (i1, i1) -> i1
    %lhs_neg_possible = "arith.andi"(%const_false, %const_true) : (i1, i1) -> i1
    %rhs_lt_lz_ub = "transfer.cmp"(%rhs1, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_lt_lo_ub = "transfer.cmp"(%rhs1, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %nsw_feasible_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_lt_lz_ub) : (i1, i1) -> i1
    %nsw_feasible_neg = "arith.andi"(%lhs_neg_possible, %rhs_lt_lo_ub) : (i1, i1) -> i1
    %nsw_feasible = "arith.ori"(%nsw_feasible_nonneg, %nsw_feasible_neg) : (i1, i1) -> i1
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs1_lt_bw = "transfer.cmp"(%rhs1, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_max_lt_bw = "transfer.cmp"(%rhs_max, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %inputs_consistent = "arith.andi"(%lhs_consistent, %rhs_consistent) : (i1, i1) -> i1
    %has_feasible_pair_base = "arith.andi"(%inputs_consistent, %rhs_min_le_bw) : (i1, i1) -> i1
    %has_feasible_pair = "arith.andi"(%has_feasible_pair_base, %nsw_feasible) : (i1, i1) -> i1

    %const_shift_res0 = "transfer.shl"(%lhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1 = "transfer.shl"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_intro_mask = "transfer.shl"(%all_ones, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_intro_zero = "transfer.xor"(%const_intro_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_intro = "transfer.select"(%rhs1_lt_bw, %const_intro_zero, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.or"(%const_shift_res0, %const_intro) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1

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
    %rhs_const_lhs_one_unknown = "arith.andi"(%rhs_is_const, %lhs_one_unknown) : (i1, i1) -> i1
    %rhs_const_lhs_two_unknown = "arith.andi"(%rhs_is_const, %lhs_two_unknown) : (i1, i1) -> i1

    %const_val0_not = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_alt = "transfer.add"(%lhs1, %lhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_alt_val = "transfer.shl"(%lhs_one_alt, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_alt_not = "transfer.xor"(%lhs_one_alt_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_res0_raw = "transfer.and"(%const_val0_not, %lhs_one_alt_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_res1_raw = "transfer.and"(%const_res1, %lhs_one_alt_val) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_res0 = "transfer.select"(%rhs_const_lhs_one_unknown, %lhs_one_res0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_res1 = "transfer.select"(%rhs_const_lhs_one_unknown, %lhs_one_res1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_two_alt1 = "transfer.add"(%lhs1, %lhs_unknown_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt2 = "transfer.add"(%lhs1, %lhs_unknown_rest) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt3 = "transfer.add"(%lhs1, %lhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_val1 = "transfer.shl"(%lhs_two_alt1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_val2 = "transfer.shl"(%lhs_two_alt2, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_val3 = "transfer.shl"(%lhs_two_alt3, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_not1 = "transfer.xor"(%lhs_two_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_not2 = "transfer.xor"(%lhs_two_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_not3 = "transfer.xor"(%lhs_two_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res0_01 = "transfer.and"(%const_val0_not, %lhs_two_not1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res0_23 = "transfer.and"(%lhs_two_not2, %lhs_two_not3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res0_raw = "transfer.and"(%lhs_two_res0_01, %lhs_two_res0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res1_01 = "transfer.and"(%const_res1, %lhs_two_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res1_23 = "transfer.and"(%lhs_two_val2, %lhs_two_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res1_raw = "transfer.and"(%lhs_two_res1_01, %lhs_two_res1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res0 = "transfer.select"(%rhs_const_lhs_two_unknown, %lhs_two_res0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_res1 = "transfer.select"(%rhs_const_lhs_two_unknown, %lhs_two_res1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %const_res0_lhs1 = "transfer.select"(%rhs_const_lhs_one_unknown, %lhs_one_res0, %const_res0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1_lhs1 = "transfer.select"(%rhs_const_lhs_one_unknown, %lhs_one_res1, %const_res1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0_lhs = "transfer.select"(%rhs_const_lhs_two_unknown, %lhs_two_res0, %const_res0_lhs1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1_lhs = "transfer.select"(%rhs_const_lhs_two_unknown, %lhs_two_res1, %const_res1_lhs1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_known_union = "transfer.or"(%rhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_mask = "transfer.xor"(%rhs_known_union, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_nonzero = "transfer.cmp"(%rhs_unknown_mask, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_unknown_minus_1 = "transfer.sub"(%rhs_unknown_mask, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_and_minus_1 = "transfer.and"(%rhs_unknown_mask, %rhs_unknown_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_unknown_pow2ish = "transfer.cmp"(%rhs_unknown_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_one_unknown = "arith.andi"(%rhs_unknown_nonzero, %rhs_unknown_pow2ish) : (i1, i1) -> i1
    %rhs_unknown_not_pow2 = "arith.xori"(%rhs_one_unknown, %const_true) : (i1, i1) -> i1

    %rhs_u2_rem = "transfer.and"(%rhs_unknown_mask, %rhs_unknown_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_rem_nonzero = "transfer.cmp"(%rhs_u2_rem, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_rem_minus_1 = "transfer.sub"(%rhs_u2_rem, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_rem_and_minus_1 = "transfer.and"(%rhs_u2_rem, %rhs_u2_rem_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_rem_pow2ish = "transfer.cmp"(%rhs_u2_rem_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_rem_pow2 = "arith.andi"(%rhs_u2_rem_nonzero, %rhs_u2_rem_pow2ish) : (i1, i1) -> i1
    %rhs_two_unknown_0 = "arith.andi"(%rhs_unknown_nonzero, %rhs_unknown_not_pow2) : (i1, i1) -> i1
    %rhs_two_unknown = "arith.andi"(%rhs_two_unknown_0, %rhs_u2_rem_pow2) : (i1, i1) -> i1

    %rhs_u3_rem1_not_pow2 = "arith.xori"(%rhs_u2_rem_pow2, %const_true) : (i1, i1) -> i1
    %rhs_u3_rem2 = "transfer.and"(%rhs_u2_rem, %rhs_u2_rem_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_rem2_nonzero = "transfer.cmp"(%rhs_u3_rem2, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_rem2_minus_1 = "transfer.sub"(%rhs_u3_rem2, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_rem2_and_minus_1 = "transfer.and"(%rhs_u3_rem2, %rhs_u3_rem2_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_rem2_pow2ish = "transfer.cmp"(%rhs_u3_rem2_and_minus_1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_rem2_pow2 = "arith.andi"(%rhs_u3_rem2_nonzero, %rhs_u3_rem2_pow2ish) : (i1, i1) -> i1
    %rhs_three_unknown_0 = "arith.andi"(%rhs_unknown_nonzero, %rhs_unknown_not_pow2) : (i1, i1) -> i1
    %rhs_three_unknown_1 = "arith.andi"(%rhs_three_unknown_0, %rhs_u3_rem1_not_pow2) : (i1, i1) -> i1
    %rhs_three_unknown = "arith.andi"(%rhs_three_unknown_1, %rhs_u3_rem2_pow2) : (i1, i1) -> i1

    %rhs_alt = "transfer.add"(%rhs1, %rhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_alt_lt_bw = "transfer.cmp"(%rhs_alt, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_alt_le_bw = "transfer.cmp"(%rhs_alt, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_alt_lt_lz_ub = "transfer.cmp"(%rhs_alt, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_alt_lt_lo_ub = "transfer.cmp"(%rhs_alt, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_alt_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_alt_lt_lz_ub) : (i1, i1) -> i1
    %rhs_alt_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_alt_lt_lo_ub) : (i1, i1) -> i1
    %rhs_alt_nsw_feasible = "arith.ori"(%rhs_alt_nsw_nonneg, %rhs_alt_nsw_neg) : (i1, i1) -> i1
    %rhs_val0_le_bw = "transfer.cmp"(%rhs1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_feas0 = "arith.andi"(%rhs_one_unknown, %rhs_val0_le_bw) : (i1, i1) -> i1
    %rhs_feas1 = "arith.andi"(%rhs_one_unknown, %rhs_alt_le_bw) : (i1, i1) -> i1
    %rhs_feas0_nsw = "arith.andi"(%rhs_feas0, %nsw_feasible) : (i1, i1) -> i1
    %rhs_feas1_nsw = "arith.andi"(%rhs_feas1, %rhs_alt_nsw_feasible) : (i1, i1) -> i1
    %rhs_any_feas_nsw = "arith.ori"(%rhs_feas0_nsw, %rhs_feas1_nsw) : (i1, i1) -> i1

    %alt_shift_res0 = "transfer.shl"(%lhs0, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %alt_res1 = "transfer.shl"(%lhs1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %alt_res1_not = "transfer.xor"(%alt_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %alt_intro_mask = "transfer.shl"(%all_ones, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %alt_intro_zero = "transfer.xor"(%alt_intro_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %alt_intro = "transfer.select"(%rhs_alt_lt_bw, %alt_intro_zero, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %alt_res0 = "transfer.or"(%alt_shift_res0, %alt_intro) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %two_sel0_0 = "transfer.select"(%rhs_feas0_nsw, %const_res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %two_sel0_1 = "transfer.select"(%rhs_feas1_nsw, %alt_res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %two_acc0 = "transfer.and"(%two_sel0_0, %two_sel0_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %two_case_res0 = "transfer.select"(%rhs_any_feas_nsw, %two_acc0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %two_sel1_0 = "transfer.select"(%rhs_feas0_nsw, %const_res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %two_sel1_1 = "transfer.select"(%rhs_feas1_nsw, %alt_res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %two_acc1 = "transfer.and"(%two_sel1_0, %two_sel1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %two_case_res1 = "transfer.select"(%rhs_any_feas_nsw, %two_acc1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u2_rem_not = "transfer.xor"(%rhs_u2_rem, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_lowbit = "transfer.and"(%rhs_unknown_mask, %rhs_u2_rem_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_highbit = "transfer.xor"(%rhs_unknown_mask, %rhs_u2_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_val1 = "transfer.add"(%rhs1, %rhs_u2_lowbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_val2 = "transfer.add"(%rhs1, %rhs_u2_highbit) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_val3 = "transfer.add"(%rhs1, %rhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u2_v0_le_bw = "transfer.cmp"(%rhs1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v1_le_bw = "transfer.cmp"(%rhs_u2_val1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v2_le_bw = "transfer.cmp"(%rhs_u2_val2, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v3_le_bw = "transfer.cmp"(%rhs_u2_val3, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v1_lt_lz_ub = "transfer.cmp"(%rhs_u2_val1, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v2_lt_lz_ub = "transfer.cmp"(%rhs_u2_val2, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v3_lt_lz_ub = "transfer.cmp"(%rhs_u2_val3, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v1_lt_lo_ub = "transfer.cmp"(%rhs_u2_val1, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v2_lt_lo_ub = "transfer.cmp"(%rhs_u2_val2, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v3_lt_lo_ub = "transfer.cmp"(%rhs_u2_val3, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v0_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u2_v1_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u2_v1_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u2_v2_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u2_v2_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u2_v3_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u2_v3_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u2_v0_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u2_v1_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u2_v1_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u2_v2_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u2_v2_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u2_v3_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u2_v3_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u2_v0_nsw = "arith.ori"(%rhs_u2_v0_nsw_nonneg, %rhs_u2_v0_nsw_neg) : (i1, i1) -> i1
    %rhs_u2_v1_nsw = "arith.ori"(%rhs_u2_v1_nsw_nonneg, %rhs_u2_v1_nsw_neg) : (i1, i1) -> i1
    %rhs_u2_v2_nsw = "arith.ori"(%rhs_u2_v2_nsw_nonneg, %rhs_u2_v2_nsw_neg) : (i1, i1) -> i1
    %rhs_u2_v3_nsw = "arith.ori"(%rhs_u2_v3_nsw_nonneg, %rhs_u2_v3_nsw_neg) : (i1, i1) -> i1
    %rhs_u2_feas0 = "arith.andi"(%rhs_two_unknown, %rhs_u2_v0_le_bw) : (i1, i1) -> i1
    %rhs_u2_feas1 = "arith.andi"(%rhs_two_unknown, %rhs_u2_v1_le_bw) : (i1, i1) -> i1
    %rhs_u2_feas2 = "arith.andi"(%rhs_two_unknown, %rhs_u2_v2_le_bw) : (i1, i1) -> i1
    %rhs_u2_feas3 = "arith.andi"(%rhs_two_unknown, %rhs_u2_v3_le_bw) : (i1, i1) -> i1
    %rhs_u2_feas0_nsw = "arith.andi"(%rhs_u2_feas0, %rhs_u2_v0_nsw) : (i1, i1) -> i1
    %rhs_u2_feas1_nsw = "arith.andi"(%rhs_u2_feas1, %rhs_u2_v1_nsw) : (i1, i1) -> i1
    %rhs_u2_feas2_nsw = "arith.andi"(%rhs_u2_feas2, %rhs_u2_v2_nsw) : (i1, i1) -> i1
    %rhs_u2_feas3_nsw = "arith.andi"(%rhs_u2_feas3, %rhs_u2_v3_nsw) : (i1, i1) -> i1
    %rhs_u2_any01 = "arith.ori"(%rhs_u2_feas0_nsw, %rhs_u2_feas1_nsw) : (i1, i1) -> i1
    %rhs_u2_any23 = "arith.ori"(%rhs_u2_feas2_nsw, %rhs_u2_feas3_nsw) : (i1, i1) -> i1
    %rhs_u2_any_nsw = "arith.ori"(%rhs_u2_any01, %rhs_u2_any23) : (i1, i1) -> i1

    %rhs_u2_shift0_1 = "transfer.shl"(%lhs0, %rhs_u2_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_shift0_2 = "transfer.shl"(%lhs0, %rhs_u2_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_shift0_3 = "transfer.shl"(%lhs0, %rhs_u2_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_v1_lt_bw = "transfer.cmp"(%rhs_u2_val1, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v2_lt_bw = "transfer.cmp"(%rhs_u2_val2, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_v3_lt_bw = "transfer.cmp"(%rhs_u2_val3, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u2_intro_mask_1 = "transfer.shl"(%all_ones, %rhs_u2_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_mask_2 = "transfer.shl"(%all_ones, %rhs_u2_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_mask_3 = "transfer.shl"(%all_ones, %rhs_u2_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_zero_1 = "transfer.xor"(%rhs_u2_intro_mask_1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_zero_2 = "transfer.xor"(%rhs_u2_intro_mask_2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_zero_3 = "transfer.xor"(%rhs_u2_intro_mask_3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_1 = "transfer.select"(%rhs_u2_v1_lt_bw, %rhs_u2_intro_zero_1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_2 = "transfer.select"(%rhs_u2_v2_lt_bw, %rhs_u2_intro_zero_2, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_intro_3 = "transfer.select"(%rhs_u2_v3_lt_bw, %rhs_u2_intro_zero_3, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_res0_1 = "transfer.or"(%rhs_u2_shift0_1, %rhs_u2_intro_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_res0_2 = "transfer.or"(%rhs_u2_shift0_2, %rhs_u2_intro_2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_res0_3 = "transfer.or"(%rhs_u2_shift0_3, %rhs_u2_intro_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel0_0 = "transfer.select"(%rhs_u2_feas0_nsw, %const_res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel0_1 = "transfer.select"(%rhs_u2_feas1_nsw, %rhs_u2_res0_1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel0_2 = "transfer.select"(%rhs_u2_feas2_nsw, %rhs_u2_res0_2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel0_3 = "transfer.select"(%rhs_u2_feas3_nsw, %rhs_u2_res0_3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_acc0_01 = "transfer.and"(%rhs_u2_sel0_0, %rhs_u2_sel0_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_acc0_23 = "transfer.and"(%rhs_u2_sel0_2, %rhs_u2_sel0_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_acc0 = "transfer.and"(%rhs_u2_acc0_01, %rhs_u2_acc0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_case_res0 = "transfer.select"(%rhs_u2_any_nsw, %rhs_u2_acc0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u2_res1_1 = "transfer.shl"(%lhs1, %rhs_u2_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_res1_2 = "transfer.shl"(%lhs1, %rhs_u2_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_res1_3 = "transfer.shl"(%lhs1, %rhs_u2_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel1_0 = "transfer.select"(%rhs_u2_feas0_nsw, %const_res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel1_1 = "transfer.select"(%rhs_u2_feas1_nsw, %rhs_u2_res1_1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel1_2 = "transfer.select"(%rhs_u2_feas2_nsw, %rhs_u2_res1_2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_sel1_3 = "transfer.select"(%rhs_u2_feas3_nsw, %rhs_u2_res1_3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_acc1_01 = "transfer.and"(%rhs_u2_sel1_0, %rhs_u2_sel1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_acc1_23 = "transfer.and"(%rhs_u2_sel1_2, %rhs_u2_sel1_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_acc1 = "transfer.and"(%rhs_u2_acc1_01, %rhs_u2_acc1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u2_case_res1 = "transfer.select"(%rhs_u2_any_nsw, %rhs_u2_acc1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_rem1_not = "transfer.xor"(%rhs_u2_rem, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_bit1 = "transfer.and"(%rhs_unknown_mask, %rhs_u3_rem1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_rest = "transfer.xor"(%rhs_unknown_mask, %rhs_u3_bit1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_rem2_not = "transfer.xor"(%rhs_u3_rem2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_bit2 = "transfer.and"(%rhs_u3_rest, %rhs_u3_rem2_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_bit3 = "transfer.xor"(%rhs_u3_rest, %rhs_u3_bit2) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_val1 = "transfer.add"(%rhs1, %rhs_u3_bit1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_val2 = "transfer.add"(%rhs1, %rhs_u3_bit2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_val3 = "transfer.add"(%rhs1, %rhs_u3_bit3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_bit12 = "transfer.add"(%rhs_u3_bit1, %rhs_u3_bit2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_bit13 = "transfer.add"(%rhs_u3_bit1, %rhs_u3_bit3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_bit23 = "transfer.add"(%rhs_u3_bit2, %rhs_u3_bit3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_val4 = "transfer.add"(%rhs1, %rhs_u3_bit12) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_val5 = "transfer.add"(%rhs1, %rhs_u3_bit13) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_val6 = "transfer.add"(%rhs1, %rhs_u3_bit23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_val7 = "transfer.add"(%rhs1, %rhs_unknown_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_v0_le_bw = "transfer.cmp"(%rhs1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v1_le_bw = "transfer.cmp"(%rhs_u3_val1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v2_le_bw = "transfer.cmp"(%rhs_u3_val2, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v3_le_bw = "transfer.cmp"(%rhs_u3_val3, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v4_le_bw = "transfer.cmp"(%rhs_u3_val4, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v5_le_bw = "transfer.cmp"(%rhs_u3_val5, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v6_le_bw = "transfer.cmp"(%rhs_u3_val6, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v7_le_bw = "transfer.cmp"(%rhs_u3_val7, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %rhs_u3_v1_lt_lz_ub = "transfer.cmp"(%rhs_u3_val1, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v2_lt_lz_ub = "transfer.cmp"(%rhs_u3_val2, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v3_lt_lz_ub = "transfer.cmp"(%rhs_u3_val3, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v4_lt_lz_ub = "transfer.cmp"(%rhs_u3_val4, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v5_lt_lz_ub = "transfer.cmp"(%rhs_u3_val5, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v6_lt_lz_ub = "transfer.cmp"(%rhs_u3_val6, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v7_lt_lz_ub = "transfer.cmp"(%rhs_u3_val7, %lhs_lz_ub) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v1_lt_lo_ub = "transfer.cmp"(%rhs_u3_val1, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v2_lt_lo_ub = "transfer.cmp"(%rhs_u3_val2, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v3_lt_lo_ub = "transfer.cmp"(%rhs_u3_val3, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v4_lt_lo_ub = "transfer.cmp"(%rhs_u3_val4, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v5_lt_lo_ub = "transfer.cmp"(%rhs_u3_val5, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v6_lt_lo_ub = "transfer.cmp"(%rhs_u3_val6, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v7_lt_lo_ub = "transfer.cmp"(%rhs_u3_val7, %lhs_lo_ub) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v0_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v1_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v1_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v2_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v2_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v3_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v3_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v4_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v4_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v5_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v5_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v6_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v6_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v7_nsw_nonneg = "arith.andi"(%lhs_nonneg_possible, %rhs_u3_v7_lt_lz_ub) : (i1, i1) -> i1
    %rhs_u3_v0_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v1_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v1_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v2_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v2_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v3_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v3_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v4_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v4_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v5_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v5_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v6_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v6_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v7_nsw_neg = "arith.andi"(%lhs_neg_possible, %rhs_u3_v7_lt_lo_ub) : (i1, i1) -> i1
    %rhs_u3_v0_nsw = "arith.ori"(%rhs_u3_v0_nsw_nonneg, %rhs_u3_v0_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v1_nsw = "arith.ori"(%rhs_u3_v1_nsw_nonneg, %rhs_u3_v1_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v2_nsw = "arith.ori"(%rhs_u3_v2_nsw_nonneg, %rhs_u3_v2_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v3_nsw = "arith.ori"(%rhs_u3_v3_nsw_nonneg, %rhs_u3_v3_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v4_nsw = "arith.ori"(%rhs_u3_v4_nsw_nonneg, %rhs_u3_v4_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v5_nsw = "arith.ori"(%rhs_u3_v5_nsw_nonneg, %rhs_u3_v5_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v6_nsw = "arith.ori"(%rhs_u3_v6_nsw_nonneg, %rhs_u3_v6_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_v7_nsw = "arith.ori"(%rhs_u3_v7_nsw_nonneg, %rhs_u3_v7_nsw_neg) : (i1, i1) -> i1
    %rhs_u3_feas0 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v0_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas1 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v1_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas2 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v2_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas3 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v3_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas4 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v4_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas5 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v5_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas6 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v6_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas7 = "arith.andi"(%rhs_three_unknown, %rhs_u3_v7_le_bw) : (i1, i1) -> i1
    %rhs_u3_feas0_nsw = "arith.andi"(%rhs_u3_feas0, %rhs_u3_v0_nsw) : (i1, i1) -> i1
    %rhs_u3_feas1_nsw = "arith.andi"(%rhs_u3_feas1, %rhs_u3_v1_nsw) : (i1, i1) -> i1
    %rhs_u3_feas2_nsw = "arith.andi"(%rhs_u3_feas2, %rhs_u3_v2_nsw) : (i1, i1) -> i1
    %rhs_u3_feas3_nsw = "arith.andi"(%rhs_u3_feas3, %rhs_u3_v3_nsw) : (i1, i1) -> i1
    %rhs_u3_feas4_nsw = "arith.andi"(%rhs_u3_feas4, %rhs_u3_v4_nsw) : (i1, i1) -> i1
    %rhs_u3_feas5_nsw = "arith.andi"(%rhs_u3_feas5, %rhs_u3_v5_nsw) : (i1, i1) -> i1
    %rhs_u3_feas6_nsw = "arith.andi"(%rhs_u3_feas6, %rhs_u3_v6_nsw) : (i1, i1) -> i1
    %rhs_u3_feas7_nsw = "arith.andi"(%rhs_u3_feas7, %rhs_u3_v7_nsw) : (i1, i1) -> i1

    %rhs_u3_any01 = "arith.ori"(%rhs_u3_feas0_nsw, %rhs_u3_feas1_nsw) : (i1, i1) -> i1
    %rhs_u3_any23 = "arith.ori"(%rhs_u3_feas2_nsw, %rhs_u3_feas3_nsw) : (i1, i1) -> i1
    %rhs_u3_any45 = "arith.ori"(%rhs_u3_feas4_nsw, %rhs_u3_feas5_nsw) : (i1, i1) -> i1
    %rhs_u3_any67 = "arith.ori"(%rhs_u3_feas6_nsw, %rhs_u3_feas7_nsw) : (i1, i1) -> i1
    %rhs_u3_any0123 = "arith.ori"(%rhs_u3_any01, %rhs_u3_any23) : (i1, i1) -> i1
    %rhs_u3_any4567 = "arith.ori"(%rhs_u3_any45, %rhs_u3_any67) : (i1, i1) -> i1
    %rhs_u3_any = "arith.ori"(%rhs_u3_any0123, %rhs_u3_any4567) : (i1, i1) -> i1

    %rhs_u3_shift0_1 = "transfer.shl"(%lhs0, %rhs_u3_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_shift0_2 = "transfer.shl"(%lhs0, %rhs_u3_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_shift0_3 = "transfer.shl"(%lhs0, %rhs_u3_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_shift0_4 = "transfer.shl"(%lhs0, %rhs_u3_val4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_shift0_5 = "transfer.shl"(%lhs0, %rhs_u3_val5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_shift0_6 = "transfer.shl"(%lhs0, %rhs_u3_val6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_shift0_7 = "transfer.shl"(%lhs0, %rhs_u3_val7) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_v1_lt_bw = "transfer.cmp"(%rhs_u3_val1, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v2_lt_bw = "transfer.cmp"(%rhs_u3_val2, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v3_lt_bw = "transfer.cmp"(%rhs_u3_val3, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v4_lt_bw = "transfer.cmp"(%rhs_u3_val4, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v5_lt_bw = "transfer.cmp"(%rhs_u3_val5, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v6_lt_bw = "transfer.cmp"(%rhs_u3_val6, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_v7_lt_bw = "transfer.cmp"(%rhs_u3_val7, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_u3_intro_mask_1 = "transfer.shl"(%all_ones, %rhs_u3_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_mask_2 = "transfer.shl"(%all_ones, %rhs_u3_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_mask_3 = "transfer.shl"(%all_ones, %rhs_u3_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_mask_4 = "transfer.shl"(%all_ones, %rhs_u3_val4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_mask_5 = "transfer.shl"(%all_ones, %rhs_u3_val5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_mask_6 = "transfer.shl"(%all_ones, %rhs_u3_val6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_mask_7 = "transfer.shl"(%all_ones, %rhs_u3_val7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_1 = "transfer.xor"(%rhs_u3_intro_mask_1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_2 = "transfer.xor"(%rhs_u3_intro_mask_2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_3 = "transfer.xor"(%rhs_u3_intro_mask_3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_4 = "transfer.xor"(%rhs_u3_intro_mask_4, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_5 = "transfer.xor"(%rhs_u3_intro_mask_5, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_6 = "transfer.xor"(%rhs_u3_intro_mask_6, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_zero_7 = "transfer.xor"(%rhs_u3_intro_mask_7, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_1 = "transfer.select"(%rhs_u3_v1_lt_bw, %rhs_u3_intro_zero_1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_2 = "transfer.select"(%rhs_u3_v2_lt_bw, %rhs_u3_intro_zero_2, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_3 = "transfer.select"(%rhs_u3_v3_lt_bw, %rhs_u3_intro_zero_3, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_4 = "transfer.select"(%rhs_u3_v4_lt_bw, %rhs_u3_intro_zero_4, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_5 = "transfer.select"(%rhs_u3_v5_lt_bw, %rhs_u3_intro_zero_5, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_6 = "transfer.select"(%rhs_u3_v6_lt_bw, %rhs_u3_intro_zero_6, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_intro_7 = "transfer.select"(%rhs_u3_v7_lt_bw, %rhs_u3_intro_zero_7, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_1 = "transfer.or"(%rhs_u3_shift0_1, %rhs_u3_intro_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_2 = "transfer.or"(%rhs_u3_shift0_2, %rhs_u3_intro_2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_3 = "transfer.or"(%rhs_u3_shift0_3, %rhs_u3_intro_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_4 = "transfer.or"(%rhs_u3_shift0_4, %rhs_u3_intro_4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_5 = "transfer.or"(%rhs_u3_shift0_5, %rhs_u3_intro_5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_6 = "transfer.or"(%rhs_u3_shift0_6, %rhs_u3_intro_6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res0_7 = "transfer.or"(%rhs_u3_shift0_7, %rhs_u3_intro_7) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_sel0_0 = "transfer.select"(%rhs_u3_feas0_nsw, %const_res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_1 = "transfer.select"(%rhs_u3_feas1_nsw, %rhs_u3_res0_1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_2 = "transfer.select"(%rhs_u3_feas2_nsw, %rhs_u3_res0_2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_3 = "transfer.select"(%rhs_u3_feas3_nsw, %rhs_u3_res0_3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_4 = "transfer.select"(%rhs_u3_feas4_nsw, %rhs_u3_res0_4, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_5 = "transfer.select"(%rhs_u3_feas5_nsw, %rhs_u3_res0_5, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_6 = "transfer.select"(%rhs_u3_feas6_nsw, %rhs_u3_res0_6, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel0_7 = "transfer.select"(%rhs_u3_feas7_nsw, %rhs_u3_res0_7, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_acc0_01 = "transfer.and"(%rhs_u3_sel0_0, %rhs_u3_sel0_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc0_23 = "transfer.and"(%rhs_u3_sel0_2, %rhs_u3_sel0_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc0_45 = "transfer.and"(%rhs_u3_sel0_4, %rhs_u3_sel0_5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc0_67 = "transfer.and"(%rhs_u3_sel0_6, %rhs_u3_sel0_7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc0_0123 = "transfer.and"(%rhs_u3_acc0_01, %rhs_u3_acc0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc0_4567 = "transfer.and"(%rhs_u3_acc0_45, %rhs_u3_acc0_67) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc0 = "transfer.and"(%rhs_u3_acc0_0123, %rhs_u3_acc0_4567) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_case_res0 = "transfer.select"(%rhs_u3_any, %rhs_u3_acc0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_res1_1 = "transfer.shl"(%lhs1, %rhs_u3_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res1_2 = "transfer.shl"(%lhs1, %rhs_u3_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res1_3 = "transfer.shl"(%lhs1, %rhs_u3_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res1_4 = "transfer.shl"(%lhs1, %rhs_u3_val4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res1_5 = "transfer.shl"(%lhs1, %rhs_u3_val5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res1_6 = "transfer.shl"(%lhs1, %rhs_u3_val6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_res1_7 = "transfer.shl"(%lhs1, %rhs_u3_val7) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_sel1_0 = "transfer.select"(%rhs_u3_feas0_nsw, %const_res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_1 = "transfer.select"(%rhs_u3_feas1_nsw, %rhs_u3_res1_1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_2 = "transfer.select"(%rhs_u3_feas2_nsw, %rhs_u3_res1_2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_3 = "transfer.select"(%rhs_u3_feas3_nsw, %rhs_u3_res1_3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_4 = "transfer.select"(%rhs_u3_feas4_nsw, %rhs_u3_res1_4, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_5 = "transfer.select"(%rhs_u3_feas5_nsw, %rhs_u3_res1_5, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_6 = "transfer.select"(%rhs_u3_feas6_nsw, %rhs_u3_res1_6, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_sel1_7 = "transfer.select"(%rhs_u3_feas7_nsw, %rhs_u3_res1_7, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_u3_acc1_01 = "transfer.and"(%rhs_u3_sel1_0, %rhs_u3_sel1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc1_23 = "transfer.and"(%rhs_u3_sel1_2, %rhs_u3_sel1_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc1_45 = "transfer.and"(%rhs_u3_sel1_4, %rhs_u3_sel1_5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc1_67 = "transfer.and"(%rhs_u3_sel1_6, %rhs_u3_sel1_7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc1_0123 = "transfer.and"(%rhs_u3_acc1_01, %rhs_u3_acc1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc1_4567 = "transfer.and"(%rhs_u3_acc1_45, %rhs_u3_acc1_67) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_acc1 = "transfer.and"(%rhs_u3_acc1_0123, %rhs_u3_acc1_4567) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_u3_case_res1 = "transfer.select"(%rhs_u3_any, %rhs_u3_acc1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_rhs_one_one = "arith.andi"(%lhs_one_unknown, %rhs_one_unknown) : (i1, i1) -> i1
    %lhs_rhs_11_val = "transfer.shl"(%lhs_one_alt, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_not = "transfer.xor"(%lhs_rhs_11_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res0_01 = "transfer.and"(%const_val0_not, %alt_res1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res0_23 = "transfer.and"(%lhs_one_alt_not, %lhs_rhs_11_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res0_raw = "transfer.and"(%lhs_rhs_11_res0_01, %lhs_rhs_11_res0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res1_01 = "transfer.and"(%const_res1, %alt_res1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res1_23 = "transfer.and"(%lhs_one_alt_val, %lhs_rhs_11_val) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res1_raw = "transfer.and"(%lhs_rhs_11_res1_01, %lhs_rhs_11_res1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res0 = "transfer.select"(%lhs_rhs_one_one, %lhs_rhs_11_res0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_11_res1 = "transfer.select"(%lhs_rhs_one_one, %lhs_rhs_11_res1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_rhs_one_two = "arith.andi"(%lhs_one_unknown, %rhs_two_unknown) : (i1, i1) -> i1
    %lhs_rhs_12_active = "arith.andi"(%lhs_rhs_one_two, %rhs_u2_any_nsw) : (i1, i1) -> i1
    %lhs_one_u2_val1 = "transfer.shl"(%lhs_one_alt, %rhs_u2_val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_u2_val2 = "transfer.shl"(%lhs_one_alt, %rhs_u2_val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_u2_val3 = "transfer.shl"(%lhs_one_alt, %rhs_u2_val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_u2_not1 = "transfer.xor"(%lhs_one_u2_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_u2_not2 = "transfer.xor"(%lhs_one_u2_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_one_u2_not3 = "transfer.xor"(%lhs_one_u2_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel0_0 = "transfer.select"(%rhs_u2_feas0_nsw, %lhs_one_alt_not, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel0_1 = "transfer.select"(%rhs_u2_feas1_nsw, %lhs_one_u2_not1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel0_2 = "transfer.select"(%rhs_u2_feas2_nsw, %lhs_one_u2_not2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel0_3 = "transfer.select"(%rhs_u2_feas3_nsw, %lhs_one_u2_not3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_acc0_01 = "transfer.and"(%lhs_12_sel0_0, %lhs_12_sel0_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_acc0_23 = "transfer.and"(%lhs_12_sel0_2, %lhs_12_sel0_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_acc0 = "transfer.and"(%lhs_12_acc0_01, %lhs_12_acc0_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_res0_raw = "transfer.and"(%const_val0_not, %lhs_12_acc0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel1_0 = "transfer.select"(%rhs_u2_feas0_nsw, %lhs_one_alt_val, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel1_1 = "transfer.select"(%rhs_u2_feas1_nsw, %lhs_one_u2_val1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel1_2 = "transfer.select"(%rhs_u2_feas2_nsw, %lhs_one_u2_val2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_sel1_3 = "transfer.select"(%rhs_u2_feas3_nsw, %lhs_one_u2_val3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_acc1_01 = "transfer.and"(%lhs_12_sel1_0, %lhs_12_sel1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_acc1_23 = "transfer.and"(%lhs_12_sel1_2, %lhs_12_sel1_3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_acc1 = "transfer.and"(%lhs_12_acc1_01, %lhs_12_acc1_23) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_12_res1_raw = "transfer.and"(%const_res1, %lhs_12_acc1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_12_res0 = "transfer.select"(%lhs_rhs_12_active, %lhs_12_res0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_12_res1 = "transfer.select"(%lhs_rhs_12_active, %lhs_12_res1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_rhs_two_one = "arith.andi"(%lhs_two_unknown, %rhs_one_unknown) : (i1, i1) -> i1
    %lhs_rhs_21_active = "arith.andi"(%lhs_rhs_two_one, %rhs_any_feas_nsw) : (i1, i1) -> i1
    %lhs_two_alt_val1 = "transfer.shl"(%lhs_two_alt1, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt_val2 = "transfer.shl"(%lhs_two_alt2, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt_val3 = "transfer.shl"(%lhs_two_alt3, %rhs_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt_not1 = "transfer.xor"(%lhs_two_alt_val1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt_not2 = "transfer.xor"(%lhs_two_alt_val2, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_two_alt_not3 = "transfer.xor"(%lhs_two_alt_val3, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_a0 = "transfer.select"(%rhs_feas0_nsw, %const_val0_not, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_a1 = "transfer.select"(%rhs_feas1_nsw, %alt_res1_not, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_b0 = "transfer.select"(%rhs_feas0_nsw, %lhs_two_not1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_b1 = "transfer.select"(%rhs_feas1_nsw, %lhs_two_alt_not1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_c0 = "transfer.select"(%rhs_feas0_nsw, %lhs_two_not2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_c1 = "transfer.select"(%rhs_feas1_nsw, %lhs_two_alt_not2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_d0 = "transfer.select"(%rhs_feas0_nsw, %lhs_two_not3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel0_d1 = "transfer.select"(%rhs_feas1_nsw, %lhs_two_alt_not3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc0_a = "transfer.and"(%lhs_21_sel0_a0, %lhs_21_sel0_a1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc0_b = "transfer.and"(%lhs_21_sel0_b0, %lhs_21_sel0_b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc0_c = "transfer.and"(%lhs_21_sel0_c0, %lhs_21_sel0_c1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc0_d = "transfer.and"(%lhs_21_sel0_d0, %lhs_21_sel0_d1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc0_ab = "transfer.and"(%lhs_21_acc0_a, %lhs_21_acc0_b) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc0_cd = "transfer.and"(%lhs_21_acc0_c, %lhs_21_acc0_d) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_res0_raw = "transfer.and"(%lhs_21_acc0_ab, %lhs_21_acc0_cd) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_a0 = "transfer.select"(%rhs_feas0_nsw, %const_res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_a1 = "transfer.select"(%rhs_feas1_nsw, %alt_res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_b0 = "transfer.select"(%rhs_feas0_nsw, %lhs_two_val1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_b1 = "transfer.select"(%rhs_feas1_nsw, %lhs_two_alt_val1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_c0 = "transfer.select"(%rhs_feas0_nsw, %lhs_two_val2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_c1 = "transfer.select"(%rhs_feas1_nsw, %lhs_two_alt_val2, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_d0 = "transfer.select"(%rhs_feas0_nsw, %lhs_two_val3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_sel1_d1 = "transfer.select"(%rhs_feas1_nsw, %lhs_two_alt_val3, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc1_a = "transfer.and"(%lhs_21_sel1_a0, %lhs_21_sel1_a1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc1_b = "transfer.and"(%lhs_21_sel1_b0, %lhs_21_sel1_b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc1_c = "transfer.and"(%lhs_21_sel1_c0, %lhs_21_sel1_c1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc1_d = "transfer.and"(%lhs_21_sel1_d0, %lhs_21_sel1_d1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc1_ab = "transfer.and"(%lhs_21_acc1_a, %lhs_21_acc1_b) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_acc1_cd = "transfer.and"(%lhs_21_acc1_c, %lhs_21_acc1_d) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_21_res1_raw = "transfer.and"(%lhs_21_acc1_ab, %lhs_21_acc1_cd) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_21_res0 = "transfer.select"(%lhs_rhs_21_active, %lhs_21_res0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_rhs_21_res1 = "transfer.select"(%lhs_rhs_21_active, %lhs_21_res1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %var_base_intro = "transfer.select"(%rhs_max_lt_bw, %const_intro_zero, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0 = "transfer.add"(%var_base_intro, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1 = "transfer.add"(%const0, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0_dyn1 = "transfer.select"(%rhs_one_unknown, %two_case_res0, %var_res0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1_dyn1 = "transfer.select"(%rhs_one_unknown, %two_case_res1, %var_res1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0_dyn2 = "transfer.select"(%rhs_two_unknown, %rhs_u2_case_res0, %var_res0_dyn1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1_dyn2 = "transfer.select"(%rhs_two_unknown, %rhs_u2_case_res1, %var_res1_dyn1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0_dyn = "transfer.select"(%rhs_three_unknown, %rhs_u3_case_res0, %var_res0_dyn2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1_dyn = "transfer.select"(%rhs_three_unknown, %rhs_u3_case_res1, %var_res1_dyn2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0_dyn_cross1 = "transfer.select"(%lhs_rhs_one_one, %lhs_rhs_11_res0, %var_res0_dyn) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1_dyn_cross1 = "transfer.select"(%lhs_rhs_one_one, %lhs_rhs_11_res1, %var_res1_dyn) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0_dyn_cross2 = "transfer.select"(%lhs_rhs_one_two, %lhs_rhs_12_res0, %var_res0_dyn_cross1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1_dyn_cross2 = "transfer.select"(%lhs_rhs_one_two, %lhs_rhs_12_res1, %var_res1_dyn_cross1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res0_dyn_cross = "transfer.select"(%lhs_rhs_two_one, %lhs_rhs_21_res0, %var_res0_dyn_cross2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %var_res1_dyn_cross = "transfer.select"(%lhs_rhs_two_one, %lhs_rhs_21_res1, %var_res1_dyn_cross2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_const_sel = "transfer.select"(%rhs_is_const, %const_res0_lhs, %var_res0_dyn_cross) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_const_sel = "transfer.select"(%rhs_is_const, %const_res1_lhs, %var_res1_dyn_cross) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1
    %res0 = "transfer.select"(%lhs_is_zero, %all_ones, %res0_const_sel) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%lhs_is_zero, %const0, %res1_const_sel) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_exact = "transfer.select"(%both_const, %const_val0_not, %res0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_exact = "transfer.select"(%both_const, %const_res1, %res1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_final = "transfer.select"(%has_feasible_pair, %res0_exact, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_final = "transfer.select"(%has_feasible_pair, %res1_exact, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0_final, %res1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_shlnuw", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
