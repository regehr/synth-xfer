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
    %lhs_consistent = "transfer.cmp"(%lhs_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_consistent = "transfer.cmp"(%rhs_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %has_feasible_pair = "arith.andi"(%lhs_consistent, %rhs_consistent) : (i1, i1) -> i1

    // or knownbits
    %or0 = "transfer.and"(%lhs0, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %or1 = "transfer.or"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // xor knownbits
    %xor0_00 = "transfer.and"(%lhs0, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_11 = "transfer.and"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_01 = "transfer.and"(%lhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_10 = "transfer.and"(%lhs1, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0 = "transfer.or"(%xor0_00, %xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1 = "transfer.or"(%xor1_01, %xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // ashr(xor, 1) knownbits
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %bw_minus_1 = "transfer.sub"(%bitwidth, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sign_mask = "transfer.shl"(%const1, %bw_minus_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_sign_zero_bits = "transfer.and"(%xor0, %sign_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_sign_one_bits = "transfer.and"(%xor1, %sign_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_nonneg = "transfer.cmp"(%xor_sign_zero_bits, %sign_mask) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %xor_neg = "transfer.cmp"(%xor_sign_one_bits, %sign_mask) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %xor_shift0 = "transfer.lshr"(%xor0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_shift1 = "transfer.lshr"(%xor1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %top_zero_mask = "transfer.select"(%xor_nonneg, %sign_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %top_one_mask = "transfer.select"(%xor_neg, %sign_mask, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %shr0 = "transfer.or"(%xor_shift0, %top_zero_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %shr1 = "transfer.or"(%xor_shift1, %top_one_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // neg(shr) = ~shr + 1
    %neg0_pre = "transfer.add"(%shr1, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg1_pre = "transfer.add"(%shr0, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %c1_0 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %c1_1 = "transfer.add"(%const1, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // add(neg_pre, const1)
    %a1_lhs_max = "transfer.xor"(%neg0_pre, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_rhs_max = "transfer.xor"(%c1_0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_sum_min = "transfer.add"(%neg1_pre, %c1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_sum_max = "transfer.add"(%a1_lhs_max, %a1_rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_min_and = "transfer.and"(%neg1_pre, %c1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_min_or = "transfer.or"(%neg1_pre, %c1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_sum_min_not = "transfer.xor"(%a1_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_min_or_and_sum_not = "transfer.and"(%a1_min_or, %a1_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_carry_out_min = "transfer.or"(%a1_min_and, %a1_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_max_and = "transfer.and"(%a1_lhs_max, %a1_rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_max_or = "transfer.or"(%a1_lhs_max, %a1_rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_sum_max_not = "transfer.xor"(%a1_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_max_or_and_sum_not = "transfer.and"(%a1_max_or, %a1_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_carry_out_max = "transfer.or"(%a1_max_and, %a1_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_carry_one = "transfer.shl"(%a1_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_carry_may_one = "transfer.shl"(%a1_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_carry_zero = "transfer.xor"(%a1_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor0_lhs_rhs_00 = "transfer.and"(%neg0_pre, %c1_0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor0_lhs_rhs_11 = "transfer.and"(%neg1_pre, %c1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor1_lhs_rhs_01 = "transfer.and"(%neg0_pre, %c1_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor1_lhs_rhs_10 = "transfer.and"(%neg1_pre, %c1_0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor_lhs_rhs_0 = "transfer.or"(%a1_xor0_lhs_rhs_00, %a1_xor0_lhs_rhs_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor_lhs_rhs_1 = "transfer.or"(%a1_xor1_lhs_rhs_01, %a1_xor1_lhs_rhs_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor0_sum_carry_00 = "transfer.and"(%a1_xor_lhs_rhs_0, %a1_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor0_sum_carry_11 = "transfer.and"(%a1_xor_lhs_rhs_1, %a1_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor1_sum_carry_01 = "transfer.and"(%a1_xor_lhs_rhs_0, %a1_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1_xor1_sum_carry_10 = "transfer.and"(%a1_xor_lhs_rhs_1, %a1_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg0 = "transfer.or"(%a1_xor0_sum_carry_00, %a1_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %neg1 = "transfer.or"(%a1_xor1_sum_carry_01, %a1_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // add(or, neg)
    %a2_lhs_max = "transfer.xor"(%or0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_rhs_max = "transfer.xor"(%neg0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_sum_min = "transfer.add"(%or1, %neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_sum_max = "transfer.add"(%a2_lhs_max, %a2_rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_min_and = "transfer.and"(%or1, %neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_min_or = "transfer.or"(%or1, %neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_sum_min_not = "transfer.xor"(%a2_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_min_or_and_sum_not = "transfer.and"(%a2_min_or, %a2_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_carry_out_min = "transfer.or"(%a2_min_and, %a2_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_max_and = "transfer.and"(%a2_lhs_max, %a2_rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_max_or = "transfer.or"(%a2_lhs_max, %a2_rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_sum_max_not = "transfer.xor"(%a2_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_max_or_and_sum_not = "transfer.and"(%a2_max_or, %a2_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_carry_out_max = "transfer.or"(%a2_max_and, %a2_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_carry_one = "transfer.shl"(%a2_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_carry_may_one = "transfer.shl"(%a2_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_carry_zero = "transfer.xor"(%a2_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor0_lhs_rhs_00 = "transfer.and"(%or0, %neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor0_lhs_rhs_11 = "transfer.and"(%or1, %neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor1_lhs_rhs_01 = "transfer.and"(%or0, %neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor1_lhs_rhs_10 = "transfer.and"(%or1, %neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor_lhs_rhs_0 = "transfer.or"(%a2_xor0_lhs_rhs_00, %a2_xor0_lhs_rhs_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor_lhs_rhs_1 = "transfer.or"(%a2_xor1_lhs_rhs_01, %a2_xor1_lhs_rhs_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor0_sum_carry_00 = "transfer.and"(%a2_xor_lhs_rhs_0, %a2_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor0_sum_carry_11 = "transfer.and"(%a2_xor_lhs_rhs_1, %a2_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor1_sum_carry_01 = "transfer.and"(%a2_xor_lhs_rhs_0, %a2_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a2_xor1_sum_carry_10 = "transfer.and"(%a2_xor_lhs_rhs_1, %a2_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.or"(%a2_xor0_sum_carry_00, %a2_xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.or"(%a2_xor1_sum_carry_01, %a2_xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_final = "transfer.select"(%has_feasible_pair, %res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_final = "transfer.select"(%has_feasible_pair, %res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0_final, %res1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_avgceils", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
