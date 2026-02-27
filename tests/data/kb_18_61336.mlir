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
    %res0_base = "transfer.or"(%res0_mid, %res0_disjoint) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_base = "transfer.or"(%res1_or, %res1_xor) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %x_known = "transfer.or"(%x0, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %y_known = "transfer.or"(%y0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %z_known = "transfer.or"(%z0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %x_unk = "transfer.xor"(%x_known, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %y_unk = "transfer.xor"(%y_known, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %z_unk = "transfer.xor"(%z_known, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %x_unk_m1 = "transfer.sub"(%x_unk, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %y_unk_m1 = "transfer.sub"(%y_unk, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %z_unk_m1 = "transfer.sub"(%z_unk, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %x_le1 = "transfer.cmp"(%x_unk_m1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %y_le1 = "transfer.cmp"(%y_unk_m1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %z_le1 = "transfer.cmp"(%z_unk_m1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %xy_le1 = "arith.andi"(%x_le1, %y_le1) : (i1, i1) -> i1
    %xyz_le1 = "arith.andi"(%xy_le1, %z_le1) : (i1, i1) -> i1
    %xv0 = "transfer.add"(%x1, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xv1 = "transfer.add"(%x1, %x_unk) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yv0 = "transfer.add"(%y1, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %yv1 = "transfer.add"(%y1, %y_unk) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %zv0 = "transfer.add"(%z1, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %zv1 = "transfer.add"(%z1, %z_unk) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_000 = "transfer.add"(%yv0, %zv0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_000 = "transfer.and"(%zv0, %s_000) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_000 = "transfer.and"(%xv0, %b_000) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_000 = "transfer.cmp"(%xb_000, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_000 = "transfer.or"(%xv0, %b_000) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_000 = "transfer.xor"(%v_000, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_000 = "transfer.select"(%feas_000, %vnot_000, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_000 = "transfer.select"(%feas_000, %v_000, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_000 = "transfer.and"(%all_ones, %sel0_000) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_000 = "transfer.and"(%all_ones, %sel1_000) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_001 = "transfer.add"(%yv0, %zv1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_001 = "transfer.and"(%zv1, %s_001) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_001 = "transfer.and"(%xv0, %b_001) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_001 = "transfer.cmp"(%xb_001, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_001 = "transfer.or"(%xv0, %b_001) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_001 = "transfer.xor"(%v_001, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_001 = "transfer.select"(%feas_001, %vnot_001, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_001 = "transfer.select"(%feas_001, %v_001, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_001 = "transfer.and"(%acc0_000, %sel0_001) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_001 = "transfer.and"(%acc1_000, %sel1_001) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_010 = "transfer.add"(%yv1, %zv0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_010 = "transfer.and"(%zv0, %s_010) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_010 = "transfer.and"(%xv0, %b_010) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_010 = "transfer.cmp"(%xb_010, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_010 = "transfer.or"(%xv0, %b_010) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_010 = "transfer.xor"(%v_010, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_010 = "transfer.select"(%feas_010, %vnot_010, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_010 = "transfer.select"(%feas_010, %v_010, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_010 = "transfer.and"(%acc0_001, %sel0_010) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_010 = "transfer.and"(%acc1_001, %sel1_010) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_011 = "transfer.add"(%yv1, %zv1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_011 = "transfer.and"(%zv1, %s_011) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_011 = "transfer.and"(%xv0, %b_011) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_011 = "transfer.cmp"(%xb_011, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_011 = "transfer.or"(%xv0, %b_011) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_011 = "transfer.xor"(%v_011, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_011 = "transfer.select"(%feas_011, %vnot_011, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_011 = "transfer.select"(%feas_011, %v_011, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_011 = "transfer.and"(%acc0_010, %sel0_011) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_011 = "transfer.and"(%acc1_010, %sel1_011) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_100 = "transfer.add"(%yv0, %zv0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_100 = "transfer.and"(%zv0, %s_100) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_100 = "transfer.and"(%xv1, %b_100) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_100 = "transfer.cmp"(%xb_100, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_100 = "transfer.or"(%xv1, %b_100) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_100 = "transfer.xor"(%v_100, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_100 = "transfer.select"(%feas_100, %vnot_100, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_100 = "transfer.select"(%feas_100, %v_100, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_100 = "transfer.and"(%acc0_011, %sel0_100) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_100 = "transfer.and"(%acc1_011, %sel1_100) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_101 = "transfer.add"(%yv0, %zv1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_101 = "transfer.and"(%zv1, %s_101) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_101 = "transfer.and"(%xv1, %b_101) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_101 = "transfer.cmp"(%xb_101, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_101 = "transfer.or"(%xv1, %b_101) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_101 = "transfer.xor"(%v_101, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_101 = "transfer.select"(%feas_101, %vnot_101, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_101 = "transfer.select"(%feas_101, %v_101, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_101 = "transfer.and"(%acc0_100, %sel0_101) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_101 = "transfer.and"(%acc1_100, %sel1_101) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_110 = "transfer.add"(%yv1, %zv0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_110 = "transfer.and"(%zv0, %s_110) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_110 = "transfer.and"(%xv1, %b_110) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_110 = "transfer.cmp"(%xb_110, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_110 = "transfer.or"(%xv1, %b_110) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_110 = "transfer.xor"(%v_110, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_110 = "transfer.select"(%feas_110, %vnot_110, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_110 = "transfer.select"(%feas_110, %v_110, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_110 = "transfer.and"(%acc0_101, %sel0_110) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_110 = "transfer.and"(%acc1_101, %sel1_110) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %s_111 = "transfer.add"(%yv1, %zv1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b_111 = "transfer.and"(%zv1, %s_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xb_111 = "transfer.and"(%xv1, %b_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %feas_111 = "transfer.cmp"(%xb_111, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %v_111 = "transfer.or"(%xv1, %b_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %vnot_111 = "transfer.xor"(%v_111, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sel0_111 = "transfer.select"(%feas_111, %vnot_111, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sel1_111 = "transfer.select"(%feas_111, %v_111, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %acc0_111 = "transfer.and"(%acc0_110, %sel0_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %acc1_111 = "transfer.and"(%acc1_110, %sel1_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_small_meet = "transfer.or"(%res0_base, %acc0_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_small_meet = "transfer.or"(%res1_base, %acc1_111) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.select"(%xyz_le1, %res0_small_meet, %res0_base) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%xyz_le1, %res1_small_meet, %res1_base) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_18_61336", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
