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

    %x_max = "transfer.xor"(%x0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %y_max = "transfer.xor"(%y0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sum_min = "transfer.add"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max = "transfer.add"(%x_max, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %min_and = "transfer.and"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or = "transfer.or"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_min_not = "transfer.xor"(%sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or_and_sum_not = "transfer.and"(%min_or, %sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_out_min = "transfer.or"(%min_and, %min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %max_and = "transfer.and"(%x_max, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_or = "transfer.or"(%x_max, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max_not = "transfer.xor"(%sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %max_or_and_sum_not = "transfer.and"(%max_or, %sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_out_max = "transfer.or"(%max_and, %max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %carry_one = "transfer.shl"(%carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_may_one = "transfer.shl"(%carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %carry_zero = "transfer.xor"(%carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_xy_00 = "transfer.and"(%x0, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_xy_11 = "transfer.and"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_xy_01 = "transfer.and"(%x0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_xy_10 = "transfer.and"(%x1, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_xy_0 = "transfer.or"(%xor0_xy_00, %xor0_xy_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_xy_1 = "transfer.or"(%xor1_xy_01, %xor1_xy_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_sum_00 = "transfer.and"(%xor_xy_0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_sum_11 = "transfer.and"(%xor_xy_1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_01 = "transfer.and"(%xor_xy_0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_10 = "transfer.and"(%xor_xy_1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum0 = "transfer.or"(%xor0_sum_00, %xor0_sum_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum1 = "transfer.or"(%xor1_sum_01, %xor1_sum_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %a0 = "transfer.or"(%y0, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %a1 = "transfer.and"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %b0_old = "transfer.or"(%x0, %sum0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_old = "transfer.and"(%x1, %sum1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_yc_00 = "transfer.and"(%y0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_yc_11 = "transfer.and"(%y1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yc_01 = "transfer.and"(%y0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yc_10 = "transfer.and"(%y1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yc_0 = "transfer.or"(%xor0_yc_00, %xor0_yc_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yc_1 = "transfer.or"(%xor1_yc_01, %xor1_yc_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %b0_alt = "transfer.or"(%x0, %xor_yc_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_alt = "transfer.and"(%x1, %xor_yc_0) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %b0_c0_raw = "transfer.or"(%x0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_c0_raw = "transfer.and"(%x1, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0_c1_raw = "transfer.or"(%x0, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_c1_raw = "transfer.and"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0_c0 = "transfer.and"(%b0_c0_raw, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_c0 = "transfer.and"(%b1_c0_raw, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0_c1 = "transfer.and"(%b0_c1_raw, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_c1 = "transfer.and"(%b1_c1_raw, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0_cases = "transfer.or"(%b0_c0, %b0_c1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_cases = "transfer.or"(%b1_c0, %b1_c1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %b0_pre = "transfer.or"(%b0_old, %b0_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1_pre = "transfer.or"(%b1_old, %b1_alt) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0 = "transfer.or"(%b0_pre, %b0_cases) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1 = "transfer.or"(%b1_pre, %b1_cases) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_or = "transfer.and"(%a0, %b0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_or = "transfer.or"(%a1, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %a0_disjoint = "transfer.or"(%a0, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b0_disjoint = "transfer.or"(%b0, %a1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_disjoint = "transfer.and"(%a0_disjoint, %b0_disjoint) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_xor_11 = "transfer.and"(%a1, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_xor = "transfer.or"(%res0_or, %res0_xor_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.or"(%res0_xor, %res0_disjoint) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1_or) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_14_63673", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
