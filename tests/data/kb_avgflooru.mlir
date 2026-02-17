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

    // and knownbits
    %and0 = "transfer.or"(%lhs0, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %and1 = "transfer.and"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // xor knownbits
    %xor0_00 = "transfer.and"(%lhs0, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_11 = "transfer.and"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_01 = "transfer.and"(%lhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_10 = "transfer.and"(%lhs1, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0 = "transfer.or"(%xor0_00, %xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1 = "transfer.or"(%xor1_01, %xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // lshr(xor, 1) knownbits
    %lshr0 = "transfer.lshr"(%xor0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr1 = "transfer.lshr"(%xor1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // add(and, lshr)
    %lhs_max = "transfer.xor"(%and0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%lshr0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sum_min = "transfer.add"(%and1, %lshr1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max = "transfer.add"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %min_and = "transfer.and"(%and1, %lshr1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or = "transfer.or"(%and1, %lshr1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_min_not = "transfer.xor"(%sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or_and_sum_not = "transfer.and"(%min_or, %sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_out_min = "transfer.or"(%min_and, %min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %max_and = "transfer.and"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_or = "transfer.or"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max_not = "transfer.xor"(%sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_or_and_sum_not = "transfer.and"(%max_or, %sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_out_max = "transfer.or"(%max_and, %max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %carry_one = "transfer.shl"(%carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_may_one = "transfer.shl"(%carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_zero = "transfer.xor"(%carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_lhs_rhs_00 = "transfer.and"(%and0, %lshr0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_lhs_rhs_11 = "transfer.and"(%and1, %lshr1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_lhs_rhs_01 = "transfer.and"(%and0, %lshr1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_lhs_rhs_10 = "transfer.and"(%and1, %lshr0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_lhs_rhs_0 = "transfer.or"(%xor0_lhs_rhs_00, %xor0_lhs_rhs_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_lhs_rhs_1 = "transfer.or"(%xor1_lhs_rhs_01, %xor1_lhs_rhs_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_sum_carry_00 = "transfer.and"(%xor_lhs_rhs_0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_sum_carry_11 = "transfer.and"(%xor_lhs_rhs_1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_carry_01 = "transfer.and"(%xor_lhs_rhs_0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_carry_10 = "transfer.and"(%xor_lhs_rhs_1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.or"(%xor0_sum_carry_00, %xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.or"(%xor1_sum_carry_01, %xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_final = "transfer.select"(%has_feasible_pair, %res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_final = "transfer.select"(%has_feasible_pair, %res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0_final, %res1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_avgflooru", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
