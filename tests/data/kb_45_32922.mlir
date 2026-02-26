"func.func"() ({
  ^0(%x : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %y : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %x0 = "transfer.get"(%x) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %x1 = "transfer.get"(%x) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %y0 = "transfer.get"(%y) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %y1 = "transfer.get"(%y) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

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

    %res0_old = "transfer.or"(%sum0, %x0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_old = "transfer.and"(%sum1, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xor0_yc_00 = "transfer.and"(%y0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_yc_11 = "transfer.and"(%y1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yc_01 = "transfer.and"(%y0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_yc_10 = "transfer.and"(%y1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yc_0 = "transfer.or"(%xor0_yc_00, %xor0_yc_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_yc_1 = "transfer.or"(%xor1_yc_01, %xor1_yc_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_new = "transfer.or"(%x0, %xor_yc_1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_new = "transfer.and"(%x1, %xor_yc_0) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.or"(%res0_old, %res0_new) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.or"(%res1_old, %res1_new) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_45_32922", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
