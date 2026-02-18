"func.func"() ({
  ^0(%lhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %rhs : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %lhs0 = "transfer.get"(%lhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %lhs1 = "transfer.get"(%lhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%lhs0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer

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
    %id_res0_l = "transfer.select"(%lhs_is_zero, %rhs0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1_l = "transfer.select"(%lhs_is_zero, %rhs1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res0 = "transfer.select"(%rhs_is_zero, %lhs0, %id_res0_l) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %id_res1 = "transfer.select"(%rhs_is_zero, %lhs1, %id_res1_l) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %const_true = "arith.constant"() {value = 1 : i1} : () -> i1
    %signed_max = "transfer.get_signed_max_value"(%lhs0) : (!transfer.integer) -> !transfer.integer
    %signed_min = "transfer.get_signed_min_value"(%lhs0) : (!transfer.integer) -> !transfer.integer

    %lhs_max = "transfer.xor"(%lhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_max = "transfer.xor"(%rhs0, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_ov = "transfer.sadd_overflow"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> i1
    %max_ov = "transfer.sadd_overflow"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> i1
    %not_min_ov = "arith.xori"(%min_ov, %const_true) : (i1, i1) -> i1
    %not_max_ov = "arith.xori"(%max_ov, %const_true) : (i1, i1) -> i1

    // KnownBits transfer for plain add.
    %const1 = "transfer.constant"(%lhs0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %sum_min = "transfer.add"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_max = "transfer.add"(%lhs_max, %rhs_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_and = "transfer.and"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min_or = "transfer.or"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
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
    %xor0_lhs_rhs_00 = "transfer.and"(%lhs0, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_lhs_rhs_11 = "transfer.and"(%lhs1, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_lhs_rhs_01 = "transfer.and"(%lhs0, %rhs1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_lhs_rhs_10 = "transfer.and"(%lhs1, %rhs0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_lhs_rhs_0 = "transfer.or"(%xor0_lhs_rhs_00, %xor0_lhs_rhs_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_lhs_rhs_1 = "transfer.or"(%xor1_lhs_rhs_01, %xor1_lhs_rhs_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_sum_carry_00 = "transfer.and"(%xor_lhs_rhs_0, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0_sum_carry_11 = "transfer.and"(%xor_lhs_rhs_1, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_carry_01 = "transfer.and"(%xor_lhs_rhs_0, %carry_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1_sum_carry_10 = "transfer.and"(%xor_lhs_rhs_1, %carry_zero) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %add0 = "transfer.or"(%xor0_sum_carry_00, %xor0_sum_carry_11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %add1 = "transfer.or"(%xor1_sum_carry_01, %xor1_sum_carry_10) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // Derive sign-known classes for each operand.
    %lhs_sign_zero_bits = "transfer.and"(%lhs0, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_zero_bits = "transfer.and"(%rhs0, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_sign_one_bits = "transfer.and"(%lhs1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %rhs_sign_one_bits = "transfer.and"(%rhs1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lhs_nonneg = "transfer.cmp"(%lhs_sign_zero_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_nonneg = "transfer.cmp"(%rhs_sign_zero_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %lhs_neg = "transfer.cmp"(%lhs_sign_one_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %rhs_neg = "transfer.cmp"(%rhs_sign_one_bits, %signed_min) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %both_nonneg = "arith.andi"(%lhs_nonneg, %rhs_nonneg) : (i1, i1) -> i1
    %both_neg = "arith.andi"(%lhs_neg, %rhs_neg) : (i1, i1) -> i1
    %mixed1 = "arith.andi"(%lhs_nonneg, %rhs_neg) : (i1, i1) -> i1
    %mixed2 = "arith.andi"(%lhs_neg, %rhs_nonneg) : (i1, i1) -> i1
    %mixed_known = "arith.ori"(%mixed1, %mixed2) : (i1, i1) -> i1

    // same-sign positive class: sat to signed_max when overflow.
    %never_nonneg = "arith.andi"(%both_nonneg, %not_max_ov) : (i1, i1) -> i1
    %must_nonneg = "arith.andi"(%both_nonneg, %min_ov) : (i1, i1) -> i1
    %not_never_nonneg = "arith.xori"(%never_nonneg, %const_true) : (i1, i1) -> i1
    %not_must_nonneg = "arith.xori"(%must_nonneg, %const_true) : (i1, i1) -> i1
    %maybe_nonneg0 = "arith.andi"(%both_nonneg, %not_never_nonneg) : (i1, i1) -> i1
    %maybe_nonneg = "arith.andi"(%maybe_nonneg0, %not_must_nonneg) : (i1, i1) -> i1
    %mix_nonneg0_raw = "transfer.and"(%add0, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_nonneg1_raw = "transfer.and"(%add1, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    // same-sign negative class: sat to signed_min when overflow.
    %never_neg = "arith.andi"(%both_neg, %not_min_ov) : (i1, i1) -> i1
    %must_neg = "arith.andi"(%both_neg, %max_ov) : (i1, i1) -> i1
    %not_never_neg = "arith.xori"(%never_neg, %const_true) : (i1, i1) -> i1
    %not_must_neg = "arith.xori"(%must_neg, %const_true) : (i1, i1) -> i1
    %maybe_neg0 = "arith.andi"(%both_neg, %not_never_neg) : (i1, i1) -> i1
    %maybe_neg = "arith.andi"(%maybe_neg0, %not_must_neg) : (i1, i1) -> i1
    %mix_neg0_raw = "transfer.and"(%add0, %signed_max) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg1_raw = "transfer.and"(%add1, %signed_min) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %no_ov_known_a = "arith.ori"(%mixed_known, %never_nonneg) : (i1, i1) -> i1
    %no_ov_known = "arith.ori"(%no_ov_known_a, %never_neg) : (i1, i1) -> i1
    %add0_exact = "transfer.select"(%no_ov_known, %add0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %add1_exact = "transfer.select"(%no_ov_known, %add1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %sat_pos0 = "transfer.select"(%must_nonneg, %signed_min, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_pos1 = "transfer.select"(%must_nonneg, %signed_max, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_neg0 = "transfer.select"(%must_neg, %signed_max, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %sat_neg1 = "transfer.select"(%must_neg, %signed_min, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_nonneg0 = "transfer.select"(%maybe_nonneg, %mix_nonneg0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_nonneg1 = "transfer.select"(%maybe_nonneg, %mix_nonneg1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg0 = "transfer.select"(%maybe_neg, %mix_neg0_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %mix_neg1 = "transfer.select"(%maybe_neg, %mix_neg1_raw, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %base00 = "transfer.or"(%id_res0, %add0_exact) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base01 = "transfer.or"(%base00, %sat_pos0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base02 = "transfer.or"(%base01, %sat_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base03 = "transfer.or"(%base02, %mix_nonneg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base0 = "transfer.or"(%base03, %mix_neg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base10 = "transfer.or"(%id_res1, %add1_exact) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base11 = "transfer.or"(%base10, %sat_pos1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base12 = "transfer.or"(%base11, %sat_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base13 = "transfer.or"(%base12, %mix_nonneg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %base1 = "transfer.or"(%base13, %mix_neg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs_is_neg = "transfer.cmp"(%lhs1, %const0) {predicate = 2 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %sat_res = "transfer.select"(%lhs_is_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res1 = "transfer.select"(%min_ov, %sat_res, %sum_min) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%both_const, %const_res0, %base0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%both_const, %const_res1, %base1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_saddsat", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
