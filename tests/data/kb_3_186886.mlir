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

    %yz_sum_min = "transfer.add"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum_max = "transfer.add"(%y_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %yz_min_and = "transfer.and"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_min_or = "transfer.or"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum_min_not = "transfer.xor"(%yz_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_min_or_and_sum_not = "transfer.and"(%yz_min_or, %yz_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_carry_out_min = "transfer.or"(%yz_min_and, %yz_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %yz_max_and = "transfer.and"(%y_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_max_or = "transfer.or"(%y_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum_max_not = "transfer.xor"(%yz_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_max_or_and_sum_not = "transfer.and"(%yz_max_or, %yz_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_carry_out_max = "transfer.or"(%yz_max_and, %yz_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %yz_carry_one = "transfer.shl"(%yz_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_carry_may_one = "transfer.shl"(%yz_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_carry_zero = "transfer.xor"(%yz_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %yz_xor0_00 = "transfer.and"(%y0, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_xor0_11 = "transfer.and"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_xor1_01 = "transfer.and"(%y0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_xor1_10 = "transfer.and"(%y1, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_xor0 = "transfer.or"(%yz_xor0_00, %yz_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_xor1 = "transfer.or"(%yz_xor1_01, %yz_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %yz_sum_xor0_00 = "transfer.and"(%yz_xor0, %yz_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum_xor0_11 = "transfer.and"(%yz_xor1, %yz_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum_xor1_01 = "transfer.and"(%yz_xor0, %yz_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum_xor1_10 = "transfer.and"(%yz_xor1, %yz_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum0 = "transfer.or"(%yz_sum_xor0_00, %yz_sum_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_sum1 = "transfer.or"(%yz_sum_xor1_01, %yz_sum_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %x_max = "transfer.xor"(%x0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yz_max2 = "transfer.xor"(%yz_sum0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res_sum_min = "transfer.add"(%x1, %yz_sum1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_sum_max = "transfer.add"(%x_max, %yz_max2) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res_min_and = "transfer.and"(%x1, %yz_sum1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_min_or = "transfer.or"(%x1, %yz_sum1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_sum_min_not = "transfer.xor"(%res_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_min_or_and_sum_not = "transfer.and"(%res_min_or, %res_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_carry_out_min = "transfer.or"(%res_min_and, %res_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res_max_and = "transfer.and"(%x_max, %yz_max2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_max_or = "transfer.or"(%x_max, %yz_max2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_sum_max_not = "transfer.xor"(%res_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_max_or_and_sum_not = "transfer.and"(%res_max_or, %res_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_carry_out_max = "transfer.or"(%res_max_and, %res_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res_carry_one = "transfer.shl"(%res_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_carry_may_one = "transfer.shl"(%res_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_carry_zero = "transfer.xor"(%res_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res_xor0_00 = "transfer.and"(%x0, %yz_sum0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_xor0_11 = "transfer.and"(%x1, %yz_sum1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_xor1_01 = "transfer.and"(%x0, %yz_sum1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_xor1_10 = "transfer.and"(%x1, %yz_sum0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_xor0 = "transfer.or"(%res_xor0_00, %res_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res_xor1 = "transfer.or"(%res_xor1_01, %res_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %out_xor0_00 = "transfer.and"(%res_xor0, %res_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out_xor0_11 = "transfer.and"(%res_xor1, %res_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out_xor1_01 = "transfer.and"(%res_xor0, %res_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out_xor1_10 = "transfer.and"(%res_xor1, %res_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out0 = "transfer.or"(%out_xor0_00, %out_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out1 = "transfer.or"(%out_xor1_01, %out_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_sum_min = "transfer.add"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum_max = "transfer.add"(%x_max, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_min_and = "transfer.and"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_min_or = "transfer.or"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum_min_not = "transfer.xor"(%xy_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_min_or_and_sum_not = "transfer.and"(%xy_min_or, %xy_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_carry_out_min = "transfer.or"(%xy_min_and, %xy_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_max_and = "transfer.and"(%x_max, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_max_or = "transfer.or"(%x_max, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum_max_not = "transfer.xor"(%xy_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_max_or_and_sum_not = "transfer.and"(%xy_max_or, %xy_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_carry_out_max = "transfer.or"(%xy_max_and, %xy_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_carry_one = "transfer.shl"(%xy_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_carry_may_one = "transfer.shl"(%xy_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_carry_zero = "transfer.xor"(%xy_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_xor0_00 = "transfer.and"(%x0, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_xor0_11 = "transfer.and"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_xor1_01 = "transfer.and"(%x0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_xor1_10 = "transfer.and"(%x1, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_xor0 = "transfer.or"(%xy_xor0_00, %xy_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_xor1 = "transfer.or"(%xy_xor1_01, %xy_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_sum_xor0_00 = "transfer.and"(%xy_xor0, %xy_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum_xor0_11 = "transfer.and"(%xy_xor1, %xy_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum_xor1_01 = "transfer.and"(%xy_xor0, %xy_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum_xor1_10 = "transfer.and"(%xy_xor1, %xy_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum0 = "transfer.or"(%xy_sum_xor0_00, %xy_sum_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xy_sum1 = "transfer.or"(%xy_sum_xor1_01, %xy_sum_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xy_max2 = "transfer.xor"(%xy_sum0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outb_sum_min = "transfer.add"(%xy_sum1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_sum_max = "transfer.add"(%xy_max2, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outb_min_and = "transfer.and"(%xy_sum1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_min_or = "transfer.or"(%xy_sum1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_sum_min_not = "transfer.xor"(%outb_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_min_or_and_sum_not = "transfer.and"(%outb_min_or, %outb_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_carry_out_min = "transfer.or"(%outb_min_and, %outb_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outb_max_and = "transfer.and"(%xy_max2, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_max_or = "transfer.or"(%xy_max2, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_sum_max_not = "transfer.xor"(%outb_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_max_or_and_sum_not = "transfer.and"(%outb_max_or, %outb_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_carry_out_max = "transfer.or"(%outb_max_and, %outb_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outb_carry_one = "transfer.shl"(%outb_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_carry_may_one = "transfer.shl"(%outb_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_carry_zero = "transfer.xor"(%outb_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outb_xor0_00 = "transfer.and"(%xy_sum0, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_xor0_11 = "transfer.and"(%xy_sum1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_xor1_01 = "transfer.and"(%xy_sum0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_xor1_10 = "transfer.and"(%xy_sum1, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_xor0 = "transfer.or"(%outb_xor0_00, %outb_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_xor1 = "transfer.or"(%outb_xor1_01, %outb_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outb_res0_00 = "transfer.and"(%outb_xor0, %outb_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_res0_11 = "transfer.and"(%outb_xor1, %outb_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_res1_01 = "transfer.and"(%outb_xor0, %outb_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb_res1_10 = "transfer.and"(%outb_xor1, %outb_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb0 = "transfer.or"(%outb_res0_00, %outb_res0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outb1 = "transfer.or"(%outb_res1_01, %outb_res1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_sum_min = "transfer.add"(%x1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum_max = "transfer.add"(%x_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_min_and = "transfer.and"(%x1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_min_or = "transfer.or"(%x1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum_min_not = "transfer.xor"(%xz_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_min_or_and_sum_not = "transfer.and"(%xz_min_or, %xz_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_carry_out_min = "transfer.or"(%xz_min_and, %xz_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_max_and = "transfer.and"(%x_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_max_or = "transfer.or"(%x_max, %z_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum_max_not = "transfer.xor"(%xz_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_max_or_and_sum_not = "transfer.and"(%xz_max_or, %xz_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_carry_out_max = "transfer.or"(%xz_max_and, %xz_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_carry_one = "transfer.shl"(%xz_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_carry_may_one = "transfer.shl"(%xz_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_carry_zero = "transfer.xor"(%xz_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_xor0_00 = "transfer.and"(%x0, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_xor0_11 = "transfer.and"(%x1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_xor1_01 = "transfer.and"(%x0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_xor1_10 = "transfer.and"(%x1, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_xor0 = "transfer.or"(%xz_xor0_00, %xz_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_xor1 = "transfer.or"(%xz_xor1_01, %xz_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_sum_xor0_00 = "transfer.and"(%xz_xor0, %xz_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum_xor0_11 = "transfer.and"(%xz_xor1, %xz_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum_xor1_01 = "transfer.and"(%xz_xor0, %xz_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum_xor1_10 = "transfer.and"(%xz_xor1, %xz_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum0 = "transfer.or"(%xz_sum_xor0_00, %xz_sum_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xz_sum1 = "transfer.or"(%xz_sum_xor1_01, %xz_sum_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %xz_max2 = "transfer.xor"(%xz_sum0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outc_sum_min = "transfer.add"(%xz_sum1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_sum_max = "transfer.add"(%xz_max2, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outc_min_and = "transfer.and"(%xz_sum1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_min_or = "transfer.or"(%xz_sum1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_sum_min_not = "transfer.xor"(%outc_sum_min, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_min_or_and_sum_not = "transfer.and"(%outc_min_or, %outc_sum_min_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_carry_out_min = "transfer.or"(%outc_min_and, %outc_min_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outc_max_and = "transfer.and"(%xz_max2, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_max_or = "transfer.or"(%xz_max2, %y_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_sum_max_not = "transfer.xor"(%outc_sum_max, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_max_or_and_sum_not = "transfer.and"(%outc_max_or, %outc_sum_max_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_carry_out_max = "transfer.or"(%outc_max_and, %outc_max_or_and_sum_not) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outc_carry_one = "transfer.shl"(%outc_carry_out_min, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_carry_may_one = "transfer.shl"(%outc_carry_out_max, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_carry_zero = "transfer.xor"(%outc_carry_may_one, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outc_xor0_00 = "transfer.and"(%xz_sum0, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_xor0_11 = "transfer.and"(%xz_sum1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_xor1_01 = "transfer.and"(%xz_sum0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_xor1_10 = "transfer.and"(%xz_sum1, %y0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_xor0 = "transfer.or"(%outc_xor0_00, %outc_xor0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_xor1 = "transfer.or"(%outc_xor1_01, %outc_xor1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %outc_res0_00 = "transfer.and"(%outc_xor0, %outc_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_res0_11 = "transfer.and"(%outc_xor1, %outc_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_res1_01 = "transfer.and"(%outc_xor0, %outc_carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc_res1_10 = "transfer.and"(%outc_xor1, %outc_carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc0 = "transfer.or"(%outc_res0_00, %outc_res0_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %outc1 = "transfer.or"(%outc_res1_01, %outc_res1_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %out0_ab = "transfer.or"(%out0, %outb0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out1_ab = "transfer.or"(%out1, %outb1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out0_meet = "transfer.or"(%out0_ab, %outc0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %out1_meet = "transfer.or"(%out1_ab, %outc1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %out0_final = "transfer.select"(%has_feasible_pair, %out0_meet, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %out1_final = "transfer.select"(%has_feasible_pair, %out1_meet, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%out0_final, %out1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_3_186886", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
