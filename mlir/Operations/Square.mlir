"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer):
    %result = "transfer.mul"(%arg0, %arg0) : (!transfer.integer, !transfer.integer) ->!transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()
}): () -> ()
