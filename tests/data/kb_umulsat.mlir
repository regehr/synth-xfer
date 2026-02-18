"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %const2 = "transfer.constant"(%lhs0) {value = 2 : index} : (!transfer.integer) -> !transfer.integer
    %const_true = "arith.constant"() {value = 1 : i1} : () -> i1
    %bitwidth = "transfer.get_bit_width"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %lhs_min_tz = "transfer.countr_one"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %rhs_min_tz = "transfer.countr_one"(%rhs0) : (!transfer.integer) -> !transfer.integer
    %tz_sum = "transfer.add"(%lhs_min_tz, %rhs_min_tz) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %tz_sum_lt_bw = "transfer.cmp"(%tz_sum, %bitwidth) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %tz_sum_clamped = "transfer.select"(%tz_sum_lt_bw, %tz_sum, %bitwidth) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %tz_sum_inv = "transfer.sub"(%bitwidth, %tz_sum_clamped) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_base = "transfer.lshr"(%all_ones, %tz_sum_inv) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_lsb_one = "transfer.and"(%lhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_lsb_one = "transfer.and"(%rhs1, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_odd = "transfer.cmp"(%lhs_lsb_one, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_odd = "transfer.cmp"(%rhs_lsb_one, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_odd = "arith.andi"(%lhs_odd, %rhs_odd) : (i1, i1) -> i1
    %res1_base = "transfer.select"(%both_odd, %const1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    // If both operands are odd, bit1 of product is xor(bit1(lhs), bit1(rhs)).
    %lhs_bit1_zero = "transfer.and"(%lhs0, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_bit1_one = "transfer.and"(%lhs1, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_bit1_zero = "transfer.and"(%rhs0, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_bit1_one = "transfer.and"(%rhs1, %const2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero_00 = "transfer.and"(%lhs_bit1_zero, %rhs_bit1_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero_11 = "transfer.and"(%lhs_bit1_one, %rhs_bit1_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero = "transfer.or"(%bit1_zero_00, %bit1_zero_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one_01 = "transfer.and"(%lhs_bit1_zero, %rhs_bit1_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one_10 = "transfer.and"(%lhs_bit1_one, %rhs_bit1_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one = "transfer.or"(%bit1_one_01, %bit1_one_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_zero_odd = "transfer.select"(%both_odd, %bit1_zero, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %bit1_one_odd = "transfer.select"(%both_odd, %bit1_one, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_precise = "transfer.or"(%res0_base, %bit1_zero_odd) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_precise = "transfer.or"(%res1_base, %bit1_one_odd) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %not_const1 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs0_is_not1 = "transfer.cmp"(%rhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_1 = "transfer.cmp"(%rhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_one = "arith.andi"(%rhs0_is_not1, %rhs1_is_1) : (i1, i1) -> i1
    %res0_rhs_one = "transfer.select"(%rhs_is_one, %lhs0, %res0_precise) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_rhs_one = "transfer.select"(%rhs_is_one, %lhs1, %res1_precise) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_is_not1 = "transfer.cmp"(%lhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_1 = "transfer.cmp"(%lhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_one = "arith.andi"(%lhs0_is_not1, %lhs1_is_1) : (i1, i1) -> i1
    %res0_lhs_one = "transfer.select"(%lhs_is_one, %rhs0, %res0_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_lhs_one = "transfer.select"(%lhs_is_one, %rhs1, %res1_rhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1
    %rhs0_all_ones = "transfer.cmp"(%rhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_zero = "arith.andi"(%rhs0_all_ones, %rhs1_is_zero) : (i1, i1) -> i1
    %either_is_zero = "arith.ori"(%lhs_is_zero, %rhs_is_zero) : (i1, i1) -> i1
    %mul0 = "transfer.select"(%either_is_zero, %all_ones, %res0_lhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mul1 = "transfer.select"(%either_is_zero, %const0, %res1_lhs_one) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_min_nonzero = "transfer.cmp"(%lhs1, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_min_nonzero = "transfer.cmp"(%rhs1, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %min_ov = "transfer.umul_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %min_nonzero = "arith.andi"(%lhs_min_nonzero, %rhs_min_nonzero) : (i1, i1) -> i1
    %always_overflow = "arith.andi"(%min_nonzero, %min_ov) : (i1, i1) -> i1
    %max_ov = "transfer.umul_overflow"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> i1
    %never_overflow = "arith.xori"(%max_ov, %const_true) : (i1, i1) -> i1

    %res0_partial = "transfer.select"(%never_overflow, %mul0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res0_sat = "transfer.select"(%always_overflow, %const0, %res0_partial) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_sat = "transfer.select"(%always_overflow, %all_ones, %mul1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1
    %const_mul = "transfer.mul"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_ov = "transfer.umul_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %const_val = "transfer.select"(%const_ov, %all_ones, %const_mul) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_val_not = "transfer.xor"(%const_val, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_val_not, %res0_sat) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_val, %res1_sat) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_umulsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
