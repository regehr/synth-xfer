"func.func"() ({
  ^0(%arg : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %x0 = "transfer.get"(%arg) {index = 0} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer

    %all_ones = "transfer.get_all_ones"(%x0) : (!transfer.integer) -> !transfer.integer
    %const0 = "transfer.constant"(%x0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%x0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer

    %bitwidth = "transfer.get_bit_width"(%x0) : (!transfer.integer) -> !transfer.integer
    %bw_lz = "transfer.countl_zero"(%bitwidth) : (!transfer.integer) -> !transfer.integer
    %used_bits = "transfer.sub"(%bitwidth, %bw_lz) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %lo_limit = "transfer.shl"(%const1, %used_bits) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %low_mask = "transfer.sub"(%lo_limit, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %res0 = "transfer.xor"(%low_mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %r = "transfer.make"(%res0, %const0) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%r) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {"sym_name" = "kb_popcount", "function_type" = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>} : () -> ()
