"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer

    %lhs1_not = "transfer.xor"(%lhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_const = "transfer.cmp"(%lhs0, %lhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_not = "transfer.xor"(%rhs1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_is_const = "transfer.cmp"(%rhs0, %rhs1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_const = "arith.andi"(%lhs_is_const, %rhs_is_const) : (i1, i1) -> i1

    %lhs0_all_ones = "transfer.cmp"(%lhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_zero = "transfer.cmp"(%lhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_zero = "arith.andi"(%lhs0_all_ones, %lhs1_is_zero) : (i1, i1) -> i1

    %rhs0_all_ones = "transfer.cmp"(%rhs0, %all_ones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_zero = "transfer.cmp"(%rhs1, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_zero = "arith.andi"(%rhs0_all_ones, %rhs1_is_zero) : (i1, i1) -> i1

    %not_const1 = "transfer.xor"(%const1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs0_is_not1 = "transfer.cmp"(%lhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_is_1 = "transfer.cmp"(%lhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_is_one = "arith.andi"(%lhs0_is_not1, %lhs1_is_1) : (i1, i1) -> i1
    %rhs0_is_not1 = "transfer.cmp"(%rhs0, %not_const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_is_1 = "transfer.cmp"(%rhs1, %const1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_one = "arith.andi"(%rhs0_is_not1, %rhs1_is_1) : (i1, i1) -> i1

    %signed_max = "transfer.get_signed_max_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %signed_min = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %mul_res = "transfer.mul"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_is_neg = "transfer.cmp"(%lhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_is_neg = "transfer.cmp"(%rhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %res_is_neg = "arith.xori"(%lhs_is_neg, %rhs_is_neg) : (i1, i1) -> i1
    %sat_res = "transfer.select"(%res_is_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %overflow = "transfer.smul_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %const_res1 = "transfer.select"(%overflow, %sat_res, %mul_res) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %id_res0_l0 = "transfer.select"(%lhs_is_zero, %all_ones, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1_l0 = "transfer.select"(%lhs_is_zero, %const0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res0_r0 = "transfer.select"(%rhs_is_zero, %all_ones, %id_res0_l0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1_r0 = "transfer.select"(%rhs_is_zero, %const0, %id_res1_l0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res0_l1 = "transfer.select"(%lhs_is_one, %rhs0, %id_res0_r0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1_l1 = "transfer.select"(%lhs_is_one, %rhs1, %id_res1_r0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res0 = "transfer.select"(%rhs_is_one, %lhs0, %id_res0_l1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1 = "transfer.select"(%rhs_is_one, %lhs1, %id_res1_l1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_res0, %id_res0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_res1, %id_res1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_smulsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
