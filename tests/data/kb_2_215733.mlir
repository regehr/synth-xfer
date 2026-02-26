"func.func"() ({
  ^0(%x : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %y : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %z : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %x0 = "transfer.get"(%x) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %x1 = "transfer.get"(%x) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %y0 = "transfer.get"(%y) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %y1 = "transfer.get"(%y) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %z0 = "transfer.get"(%z) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %z1 = "transfer.get"(%z) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%x0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%x0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%x0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer

    %x_conflict = "transfer.and"(%x0, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %y_conflict = "transfer.and"(%y0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %z_conflict = "transfer.and"(%z0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %x_consistent = "transfer.cmp"(%x_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %y_consistent = "transfer.cmp"(%y_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %z_consistent = "transfer.cmp"(%z_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %xy_consistent = "arith.andi"(%x_consistent, %y_consistent) : (i1, i1) -> i1
    %has_feasible_pair = "arith.andi"(%xy_consistent, %z_consistent) : (i1, i1) -> i1

    %y_max = "transfer.xor"(%y0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %z_max = "transfer.xor"(%z0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sum_min = "transfer.add"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max = "transfer.add"(%y_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %min_and = "transfer.and"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or = "transfer.or"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_min_not = "transfer.xor"(%sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or_and_sum_not = "transfer.and"(%min_or, %sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_out_min = "transfer.or"(%min_and, %min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %max_and = "transfer.and"(%y_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_or = "transfer.or"(%y_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max_not = "transfer.xor"(%sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_or_and_sum_not = "transfer.and"(%max_or, %sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_out_max = "transfer.or"(%max_and, %max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %carry_one = "transfer.shl"(%carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_may_one = "transfer.shl"(%carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_zero = "transfer.xor"(%carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_yz_00 = "transfer.and"(%y0, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_yz_11 = "transfer.and"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yz_01 = "transfer.and"(%y0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yz_10 = "transfer.and"(%y1, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yz_0 = "transfer.or"(%xor0_yz_00, %xor0_yz_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yz_1 = "transfer.or"(%xor1_yz_01, %xor1_yz_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_sum_00 = "transfer.and"(%xor_yz_0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_sum_11 = "transfer.and"(%xor_yz_1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_01 = "transfer.and"(%xor_yz_0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_10 = "transfer.and"(%xor_yz_1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum0_kb = "transfer.or"(%xor0_sum_00, %xor0_sum_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum1_kb = "transfer.or"(%xor1_sum_01, %xor1_sum_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.or"(%x0, %sum0_kb) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.and"(%x1, %sum1_kb) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_final = "transfer.select"(%has_feasible_pair, %res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_final = "transfer.select"(%has_feasible_pair, %res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0_final, %res1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_2_215733", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
