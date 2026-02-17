"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %const1_not = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %smax = "transfer.get_signed_max_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %smin = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %n_rhs_a_max = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_b_max = "transfer.xor"(%const1_not, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum_min = "transfer.add"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum_max = "transfer.add"(%n_rhs_a_max, %n_rhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_min_and = "transfer.and"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_min_or = "transfer.or"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum_min_not = "transfer.xor"(%n_rhs_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_min_or_and_sum_not = "transfer.and"(%n_rhs_min_or, %n_rhs_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry_out_min = "transfer.or"(%n_rhs_min_and, %n_rhs_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_max_and = "transfer.and"(%n_rhs_a_max, %n_rhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_max_or = "transfer.or"(%n_rhs_a_max, %n_rhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum_max_not = "transfer.xor"(%n_rhs_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_max_or_and_sum_not = "transfer.and"(%n_rhs_max_or, %n_rhs_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry_out_max = "transfer.or"(%n_rhs_max_and, %n_rhs_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry_one = "transfer.shl"(%n_rhs_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry_may_one = "transfer.shl"(%n_rhs_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry_zero = "transfer.xor"(%n_rhs_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor0_ab_00 = "transfer.and"(%rhs1, %const1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor0_ab_11 = "transfer.and"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor1_ab_01 = "transfer.and"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor1_ab_10 = "transfer.and"(%rhs0, %const1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor_ab_0 = "transfer.or"(%n_rhs_xor0_ab_00, %n_rhs_xor0_ab_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor_ab_1 = "transfer.or"(%n_rhs_xor1_ab_01, %n_rhs_xor1_ab_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor0_sum_carry_00 = "transfer.and"(%n_rhs_xor_ab_0, %n_rhs_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor0_sum_carry_11 = "transfer.and"(%n_rhs_xor_ab_1, %n_rhs_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor1_sum_carry_01 = "transfer.and"(%n_rhs_xor_ab_0, %n_rhs_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor1_sum_carry_10 = "transfer.and"(%n_rhs_xor_ab_1, %n_rhs_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_neg0 = "transfer.or"(%n_rhs_xor0_sum_carry_00, %n_rhs_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_neg1 = "transfer.or"(%n_rhs_xor1_sum_carry_01, %n_rhs_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %n_lhs_a_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_b_max = "transfer.xor"(%rhs_neg0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_sum_min = "transfer.add"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_sum_max = "transfer.add"(%n_lhs_a_max, %n_lhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_min_and = "transfer.and"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_min_or = "transfer.or"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_sum_min_not = "transfer.xor"(%n_lhs_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_min_or_and_sum_not = "transfer.and"(%n_lhs_min_or, %n_lhs_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_carry_out_min = "transfer.or"(%n_lhs_min_and, %n_lhs_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_max_and = "transfer.and"(%n_lhs_a_max, %n_lhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_max_or = "transfer.or"(%n_lhs_a_max, %n_lhs_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_sum_max_not = "transfer.xor"(%n_lhs_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_max_or_and_sum_not = "transfer.and"(%n_lhs_max_or, %n_lhs_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_carry_out_max = "transfer.or"(%n_lhs_max_and, %n_lhs_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_carry_one = "transfer.shl"(%n_lhs_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_carry_may_one = "transfer.shl"(%n_lhs_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_carry_zero = "transfer.xor"(%n_lhs_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor0_ab_00 = "transfer.and"(%lhs0, %rhs_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor0_ab_11 = "transfer.and"(%lhs1, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor1_ab_01 = "transfer.and"(%lhs0, %rhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor1_ab_10 = "transfer.and"(%lhs1, %rhs_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor_ab_0 = "transfer.or"(%n_lhs_xor0_ab_00, %n_lhs_xor0_ab_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor_ab_1 = "transfer.or"(%n_lhs_xor1_ab_01, %n_lhs_xor1_ab_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor0_sum_carry_00 = "transfer.and"(%n_lhs_xor_ab_0, %n_lhs_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor0_sum_carry_11 = "transfer.and"(%n_lhs_xor_ab_1, %n_lhs_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor1_sum_carry_01 = "transfer.and"(%n_lhs_xor_ab_0, %n_lhs_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhs_xor1_sum_carry_10 = "transfer.and"(%n_lhs_xor_ab_1, %n_lhs_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_lr0 = "transfer.or"(%n_lhs_xor0_sum_carry_00, %n_lhs_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_lr1 = "transfer.or"(%n_lhs_xor1_sum_carry_01, %n_lhs_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %n_lhsn_a_max = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_b_max = "transfer.xor"(%const1_not, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_sum_min = "transfer.add"(%lhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_sum_max = "transfer.add"(%n_lhsn_a_max, %n_lhsn_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_min_and = "transfer.and"(%lhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_min_or = "transfer.or"(%lhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_sum_min_not = "transfer.xor"(%n_lhsn_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_min_or_and_sum_not = "transfer.and"(%n_lhsn_min_or, %n_lhsn_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_carry_out_min = "transfer.or"(%n_lhsn_min_and, %n_lhsn_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_max_and = "transfer.and"(%n_lhsn_a_max, %n_lhsn_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_max_or = "transfer.or"(%n_lhsn_a_max, %n_lhsn_b_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_sum_max_not = "transfer.xor"(%n_lhsn_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_max_or_and_sum_not = "transfer.and"(%n_lhsn_max_or, %n_lhsn_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_carry_out_max = "transfer.or"(%n_lhsn_max_and, %n_lhsn_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_carry_one = "transfer.shl"(%n_lhsn_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_carry_may_one = "transfer.shl"(%n_lhsn_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_carry_zero = "transfer.xor"(%n_lhsn_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor0_ab_00 = "transfer.and"(%lhs1, %const1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor0_ab_11 = "transfer.and"(%lhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor1_ab_01 = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor1_ab_10 = "transfer.and"(%lhs0, %const1_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor_ab_0 = "transfer.or"(%n_lhsn_xor0_ab_00, %n_lhsn_xor0_ab_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor_ab_1 = "transfer.or"(%n_lhsn_xor1_ab_01, %n_lhsn_xor1_ab_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor0_sum_carry_00 = "transfer.and"(%n_lhsn_xor_ab_0, %n_lhsn_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor0_sum_carry_11 = "transfer.and"(%n_lhsn_xor_ab_1, %n_lhsn_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor1_sum_carry_01 = "transfer.and"(%n_lhsn_xor_ab_0, %n_lhsn_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_lhsn_xor1_sum_carry_10 = "transfer.and"(%n_lhsn_xor_ab_1, %n_lhsn_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_neg0 = "transfer.or"(%n_lhsn_xor0_sum_carry_00, %n_lhsn_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_neg1 = "transfer.or"(%n_lhsn_xor1_sum_carry_01, %n_lhsn_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %n_rhs_a2_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_b2_max = "transfer.xor"(%lhs_neg0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum2_min = "transfer.add"(%rhs1, %lhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum2_max = "transfer.add"(%n_rhs_a2_max, %n_rhs_b2_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_min2_and = "transfer.and"(%rhs1, %lhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_min2_or = "transfer.or"(%rhs1, %lhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum2_min_not = "transfer.xor"(%n_rhs_sum2_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_min2_or_and_sum_not = "transfer.and"(%n_rhs_min2_or, %n_rhs_sum2_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry2_out_min = "transfer.or"(%n_rhs_min2_and, %n_rhs_min2_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_max2_and = "transfer.and"(%n_rhs_a2_max, %n_rhs_b2_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_max2_or = "transfer.or"(%n_rhs_a2_max, %n_rhs_b2_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_sum2_max_not = "transfer.xor"(%n_rhs_sum2_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_max2_or_and_sum_not = "transfer.and"(%n_rhs_max2_or, %n_rhs_sum2_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry2_out_max = "transfer.or"(%n_rhs_max2_and, %n_rhs_max2_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry2_one = "transfer.shl"(%n_rhs_carry2_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry2_may_one = "transfer.shl"(%n_rhs_carry2_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_carry2_zero = "transfer.xor"(%n_rhs_carry2_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_ab_00 = "transfer.and"(%rhs0, %lhs_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_ab_11 = "transfer.and"(%rhs1, %lhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_ab_01 = "transfer.and"(%rhs0, %lhs_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_ab_10 = "transfer.and"(%rhs1, %lhs_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_0 = "transfer.or"(%n_rhs_xor2_ab_00, %n_rhs_xor2_ab_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_1 = "transfer.or"(%n_rhs_xor2_ab_01, %n_rhs_xor2_ab_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_sum_carry_00 = "transfer.and"(%n_rhs_xor2_0, %n_rhs_carry2_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_sum_carry_11 = "transfer.and"(%n_rhs_xor2_1, %n_rhs_carry2_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_sum_carry_01 = "transfer.and"(%n_rhs_xor2_0, %n_rhs_carry2_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %n_rhs_xor2_sum_carry_10 = "transfer.and"(%n_rhs_xor2_1, %n_rhs_carry2_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_rl0 = "transfer.or"(%n_rhs_xor2_sum_carry_00, %n_rhs_xor2_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub_rl1 = "transfer.or"(%n_rhs_xor2_sum_carry_01, %n_rhs_xor2_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %join0 = "transfer.and"(%sub_lr0, %sub_rl0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %join1 = "transfer.and"(%sub_lr1, %sub_rl1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_smin_sign = "transfer.and"(%lhs_max, %smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_smin = "transfer.or"(%lhs1, %lhs_smin_sign) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_upper_max = "transfer.and"(%lhs_max, %smax) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_smax = "transfer.or"(%lhs_upper_max, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %rhs_smin_sign = "transfer.and"(%rhs_max, %smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_smin = "transfer.or"(%rhs1, %rhs_smin_sign) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_upper_max = "transfer.and"(%rhs_max, %smax) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_smax = "transfer.or"(%rhs_upper_max, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_ge_rhs_always = "transfer.cmp"(%lhs_smin, %rhs_smax) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_lt_rhs_always = "transfer.cmp"(%lhs_smax, %rhs_smin) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %res0_uncertain = "transfer.select"(%lhs_lt_rhs_always, %sub_rl0, %join0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_uncertain = "transfer.select"(%lhs_lt_rhs_always, %sub_rl1, %join1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_nonconst = "transfer.select"(%lhs_ge_rhs_always, %sub_lr0, %res0_uncertain) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_nonconst = "transfer.select"(%lhs_ge_rhs_always, %sub_lr1, %res1_uncertain) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_sign_zero = "transfer.and"(%lhs0, %smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_zero = "transfer.and"(%rhs0, %smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_sign_one = "transfer.and"(%lhs1, %smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_one = "transfer.and"(%rhs1, %smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_nonneg_known = "transfer.cmp"(%lhs_sign_zero, %smin) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_nonneg_known = "transfer.cmp"(%rhs_sign_zero, %smin) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_neg_known = "transfer.cmp"(%lhs_sign_one, %smin) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_neg_known = "transfer.cmp"(%rhs_sign_one, %smin) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_nonneg_known = "arith.andi"(%lhs_nonneg_known, %rhs_nonneg_known) : (i1, i1) -> i1
    %both_neg_known = "arith.andi"(%lhs_neg_known, %rhs_neg_known) : (i1, i1) -> i1
    %same_sign_known = "arith.ori"(%both_nonneg_known, %both_neg_known) : (i1, i1) -> i1
    %same_sign_nonneg_mask = "transfer.select"(%same_sign_known, %smin, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_nonneg_rhs_neg = "arith.andi"(%lhs_nonneg_known, %rhs_neg_known) : (i1, i1) -> i1
    %lr_min_ov = "transfer.ssub_overflow"(%lhs_smin, %rhs_smax) : (!transfer.integer, !transfer.integer) -> i1
    %lr_max_ov = "transfer.ssub_overflow"(%lhs_smax, %rhs_smin) : (!transfer.integer, !transfer.integer) -> i1
    %lr_sign_zero_pre = "transfer.select"(%lr_max_ov, %const0, %smin) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lr_sign_zero_mask = "transfer.select"(%lhs_nonneg_rhs_neg, %lr_sign_zero_pre, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lr_sign_one_pre = "transfer.select"(%lr_min_ov, %smin, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %lr_sign_one_mask = "transfer.select"(%lhs_nonneg_rhs_neg, %lr_sign_one_pre, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_neg_rhs_nonneg = "arith.andi"(%lhs_neg_known, %rhs_nonneg_known) : (i1, i1) -> i1
    %rl_min_ov = "transfer.ssub_overflow"(%rhs_smin, %lhs_smax) : (!transfer.integer, !transfer.integer) -> i1
    %rl_max_ov = "transfer.ssub_overflow"(%rhs_smax, %lhs_smin) : (!transfer.integer, !transfer.integer) -> i1
    %rl_sign_zero_pre = "transfer.select"(%rl_max_ov, %const0, %smin) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rl_sign_zero_mask = "transfer.select"(%lhs_neg_rhs_nonneg, %rl_sign_zero_pre, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rl_sign_one_pre = "transfer.select"(%rl_min_ov, %smin, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rl_sign_one_mask = "transfer.select"(%lhs_neg_rhs_nonneg, %rl_sign_one_pre, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %sign_zero_mask_a = "transfer.or"(%same_sign_nonneg_mask, %lr_sign_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sign_zero_mask = "transfer.or"(%sign_zero_mask_a, %rl_sign_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sign_one_mask = "transfer.or"(%lr_sign_one_mask, %rl_sign_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sign_one_clear_mask = "transfer.xor"(%sign_one_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sign_zero_clear_mask = "transfer.xor"(%sign_zero_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_sign_base = "transfer.and"(%res0_nonconst, %sign_one_clear_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_sign_base = "transfer.and"(%res1_nonconst, %sign_zero_clear_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_signed = "transfer.or"(%res0_sign_base, %sign_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_signed = "transfer.or"(%res1_sign_base, %sign_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %same_diff1_ge = "transfer.cmp"(%lhs_smin, %rhs_smax) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %same_diff1_ab = "transfer.sub"(%lhs_smin, %rhs_smax) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %same_diff1_ba = "transfer.sub"(%rhs_smax, %lhs_smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %same_diff1 = "transfer.select"(%same_diff1_ge, %same_diff1_ab, %same_diff1_ba) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %same_diff2_ge = "transfer.cmp"(%lhs_smax, %rhs_smin) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %same_diff2_ab = "transfer.sub"(%lhs_smax, %rhs_smin) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %same_diff2_ba = "transfer.sub"(%rhs_smin, %lhs_smax) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %same_diff2 = "transfer.select"(%same_diff2_ge, %same_diff2_ab, %same_diff2_ba) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %same_sign_ub = "transfer.umax"(%same_diff1, %same_diff2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %same_sign_ub_lz = "transfer.countl_zero"(%same_sign_ub) : (!transfer.integer) -> !transfer.integer
    %same_sign_shift = "transfer.sub"(%bitwidth, %same_sign_ub_lz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %same_sign_high_zero = "transfer.shl"(%all_ones, %same_sign_shift) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %same_sign_high_zero_mask = "transfer.select"(%same_sign_known, %same_sign_high_zero, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %same_sign_high_zero_clear = "transfer.xor"(%same_sign_high_zero_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_same_sign = "transfer.or"(%res0_signed, %same_sign_high_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_same_sign = "transfer.and"(%res1_signed, %same_sign_high_zero_clear) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_low0 = "transfer.and"(%lhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_low1 = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_low0 = "transfer.and"(%rhs0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_low1 = "transfer.and"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero_eq00 = "transfer.and"(%lhs_low0, %rhs_low0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero_eq11 = "transfer.and"(%lhs_low1, %rhs_low1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one_neq01 = "transfer.and"(%lhs_low0, %rhs_low1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one_neq10 = "transfer.and"(%lhs_low1, %rhs_low0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero_mask = "transfer.or"(%lsb_zero_eq00, %lsb_zero_eq11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one_mask = "transfer.or"(%lsb_one_neq01, %lsb_one_neq10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_one_clear_mask = "transfer.xor"(%lsb_one_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lsb_zero_clear_mask = "transfer.xor"(%lsb_zero_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_lsb_base = "transfer.and"(%res0_same_sign, %lsb_one_clear_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lsb_base = "transfer.and"(%res1_same_sign, %lsb_zero_clear_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_refined = "transfer.or"(%res0_lsb_base, %lsb_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_refined = "transfer.or"(%res1_lsb_base, %lsb_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1

    %const_sub_lr = "transfer.sub"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_sub_rl = "transfer.sub"(%rhs1, %lhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_lhs_ge_rhs = "transfer.cmp"(%lhs1, %rhs1) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const_val = "transfer.select"(%const_lhs_ge_rhs, %const_sub_lr, %const_sub_rl) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_val_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_val_not, %res0_refined) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_val, %res1_refined) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_abds", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
