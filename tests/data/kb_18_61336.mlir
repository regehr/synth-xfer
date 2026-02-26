"func.func"() ({
  ^0(%x : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %y : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %z : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %x0 = "transfer.get"(%x) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %x1 = "transfer.get"(%x) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %y0 = "transfer.get"(%y) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %y1 = "transfer.get"(%y) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %z0 = "transfer.get"(%z) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %z1 = "transfer.get"(%z) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%x0) : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%x0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer

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

    %b0_old = "transfer.or"(%sum0_kb, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_old = "transfer.and"(%sum1_kb, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_yc_00 = "transfer.and"(%y0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_yc_11 = "transfer.and"(%y1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yc_01 = "transfer.and"(%y0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yc_10 = "transfer.and"(%y1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yc_0 = "transfer.or"(%xor0_yc_00, %xor0_yc_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yc_1 = "transfer.or"(%xor1_yc_01, %xor1_yc_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0_new = "transfer.or"(%z0, %xor_yc_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_new = "transfer.and"(%z1, %xor_yc_0) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %b0 = "transfer.or"(%b0_old, %b0_new) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1 = "transfer.or"(%b1_old, %b1_new) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_or = "transfer.and"(%x0, %b0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_or = "transfer.or"(%x1, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_xb_00 = "transfer.and"(%x0, %b0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_xb_11 = "transfer.and"(%x1, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_xb_01 = "transfer.and"(%x0, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_xb_10 = "transfer.and"(%x1, %b0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_xor = "transfer.or"(%xor0_xb_00, %xor0_xb_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_xor = "transfer.or"(%xor1_xb_01, %xor1_xb_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_disjoint_left = "transfer.or"(%x0, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_disjoint_right = "transfer.or"(%b0, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_disjoint = "transfer.and"(%res0_disjoint_left, %res0_disjoint_right) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_mid = "transfer.or"(%res0_or, %res0_xor) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.or"(%res0_mid, %res0_disjoint) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.or"(%res1_or, %res1_xor) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_18_61336", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
