"func.func"() ({
  ^0(%arg : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %x0 = "transfer.get"(%arg) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %x1 = "transfer.get"(%arg) {index = 1} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%x0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%x0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer

    %x1_not = "transfer.xor"(%x1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %x_is_const = "transfer.cmp"(%x0, %x1_not) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1

    %const_res1 = "transfer.mul"(%x1, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %const_res0 = "transfer.xor"(%const_res1, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0 = "transfer.select"(%x_is_const, %const_res0, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.select"(%x_is_const, %const_res1, %const0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %res1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_square", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
