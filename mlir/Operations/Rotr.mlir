"builtin.module"() ({
  "func.func"() ({
  ^bb0(%a: !transfer.integer, %s: !transfer.integer):
    %bw = "transfer.get_bit_width"(%a) : (!transfer.integer) -> !transfer.integer
    %k = "transfer.urem"(%s, %bw) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %inv_k = "transfer.sub"(%bw, %k) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr_part = "transfer.lshr"(%a, %k) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %shl_part = "transfer.shl"(%a, %inv_k) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res = "transfer.or"(%lshr_part, %shl_part) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%res) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()
}): () -> ()
