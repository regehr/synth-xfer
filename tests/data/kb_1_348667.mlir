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

    %x_conflict = "transfer.and"(%x0, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %y_conflict = "transfer.and"(%y0, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %z_conflict = "transfer.and"(%z0, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %x_consistent = "transfer.cmp"(%x_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %y_consistent = "transfer.cmp"(%y_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %z_consistent = "transfer.cmp"(%z_conflict, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %xy_consistent = "arith.andi"(%x_consistent, %y_consistent) : (i1, i1) -> i1
    %xyz_consistent = "arith.andi"(%xy_consistent, %z_consistent) : (i1, i1) -> i1

    %xy1 = "transfer.and"(%x1, %y1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %forced_overlap = "transfer.and"(%xy1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %no_forced_overlap = "transfer.cmp"(%forced_overlap, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %has_feasible_pair = "arith.andi"(%xyz_consistent, %no_forced_overlap) : (i1, i1) -> i1

    %b0 = "transfer.or"(%y0, %z0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %b1 = "transfer.and"(%y1, %z1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %left0 = "transfer.or"(%x0, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %right0 = "transfer.or"(%b0, %x1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.and"(%left0, %right0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res1 = "transfer.or"(%x1, %b1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %res0_final = "transfer.select"(%has_feasible_pair, %res0, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res1_final = "transfer.select"(%has_feasible_pair, %res1, %all_ones) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0_final, %res1_final) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_1_348667", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
