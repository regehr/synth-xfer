"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer

    %lhs_conflict = "transfer.and"(%lhs0, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_conflict = "transfer.and"(%rhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %any_conflict = "transfer.or"(%lhs_conflict, %rhs_conflict) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %consistent = "transfer.cmp"(%any_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %always_underflow = "transfer.cmp"(%lhs_max, %rhs1) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %never_underflow = "transfer.cmp"(%lhs1, %rhs_max) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %rhs_min_le_lhs_max = "transfer.cmp"(%rhs1, %lhs_max) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %ub_non_raw = "transfer.sub"(%lhs_max, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %ub_non = "transfer.select"(%rhs_min_le_lhs_max, %ub_non_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %ub = "transfer.select"(%always_underflow, %const0, %ub_non) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lb_raw = "transfer.sub"(%lhs1, %rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lb = "transfer.select"(%never_underflow, %lb_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %diff = "transfer.xor"(%lb, %ub) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %common_lz = "transfer.countl_zero"(%diff) : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %common_inv = "transfer.sub"(%bitwidth, %common_lz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %common_mask = "transfer.shl"(%all_ones, %common_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lb_not = "transfer.xor"(%lb, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range0 = "transfer.and"(%lb_not, %common_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %range1 = "transfer.and"(%lb, %common_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1
    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1
    %rhs0_all_ones = "transfer.cmp"(%rhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_zero = "arith.andi"(%rhs0_all_ones, %rhs1_is_zero) : (i1, i1) -> i1

    %const_underflow = "transfer.cmp"(%lhs1, %rhs1) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const_sub = "transfer.sub"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1 = "transfer.select"(%const_underflow, %const0, %const_sub) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_uf = "transfer.select"(%always_underflow, %all_ones, %range0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_uf = "transfer.select"(%always_underflow, %const0, %range1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_lhs0 = "transfer.select"(%lhs_is_zero, %all_ones, %res0_uf) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lhs0 = "transfer.select"(%lhs_is_zero, %const0, %res1_uf) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_rhs0 = "transfer.select"(%rhs_is_zero, %lhs0, %res0_lhs0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs0 = "transfer.select"(%rhs_is_zero, %lhs1, %res1_lhs0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.select"(%both_const, %const_res0, %res0_rhs0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_res1, %res1_rhs0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    // Compute lhs-rhs (mod 2^bw) known bits using (~rhs + 1) and add-style carry reasoning.
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
    %sub_lr0 = "transfer.or"(%sub_xor0_sum_carry_00, %sub_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_lr1 = "transfer.or"(%sub_xor1_sum_carry_01, %sub_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_lr1_nouf = "transfer.select"(%never_underflow, %sub_lr1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_sub = "transfer.or"(%res0, %sub_lr0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_sub = "transfer.or"(%res1, %sub_lr1_nouf) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // Equal low bits imply trailing zeros in lhs-rhs; parity gives the exact low bit.
    %eq_low_known0 = "transfer.and"(%lhs0, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq_low_known1 = "transfer.and"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq_low_known = "transfer.or"(%eq_low_known0, %eq_low_known1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq_low_count = "transfer.countr_one"(%eq_low_known) : (!transfer.integer) -> !transfer.integer
    %eq_low_inv = "transfer.sub"(%bitwidth, %eq_low_count) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq_low_mask = "transfer.lshr"(%all_ones, %eq_low_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_eq = "transfer.or"(%res0_sub, %eq_low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_lsb0 = "transfer.and"(%lhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_lsb1 = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_lsb0 = "transfer.and"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_lsb1 = "transfer.and"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero00 = "transfer.and"(%lhs_lsb0, %rhs_lsb0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero11 = "transfer.and"(%lhs_lsb1, %rhs_lsb1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one01 = "transfer.and"(%lhs_lsb0, %rhs_lsb1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one10 = "transfer.and"(%lhs_lsb1, %rhs_lsb0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero = "transfer.or"(%lsb_zero00, %lsb_zero11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one = "transfer.or"(%lsb_one01, %lsb_one10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one_nouf = "transfer.select"(%never_underflow, %lsb_one, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_lsb = "transfer.or"(%res0_eq, %lsb_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lsb = "transfer.or"(%res1_sub, %lsb_one_nouf) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // Low known input bits give exact low bits of lhs-rhs (mod 2^k).
    %lhs_known_mask = "transfer.or"(%lhs0, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_known_mask = "transfer.or"(%rhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_low_known = "transfer.countr_one"(%lhs_known_mask) : (!transfer.integer) -> !transfer.integer
    %rhs_low_known = "transfer.countr_one"(%rhs_known_mask) : (!transfer.integer) -> !transfer.integer
    %low_known = "transfer.umin"(%lhs_low_known, %rhs_low_known) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_inv = "transfer.sub"(%bitwidth, %low_known) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_mask = "transfer.lshr"(%all_ones, %low_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_low = "transfer.and"(%lhs1, %low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_low = "transfer.and"(%rhs1, %low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_sub = "transfer.sub"(%lhs_low, %rhs_low) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_sub_masked = "transfer.and"(%low_sub, %low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_sub_not = "transfer.xor"(%low_sub_masked, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low0 = "transfer.and"(%low_sub_not, %low_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low1 = "transfer.select"(%never_underflow, %low_sub_masked, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_refined = "transfer.or"(%res0_lsb, %low0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_refined = "transfer.or"(%res1_lsb, %low1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_final = "transfer.select"(%consistent, %res0_refined, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_final = "transfer.select"(%consistent, %res1_refined, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0_final, %res1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_usubsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
