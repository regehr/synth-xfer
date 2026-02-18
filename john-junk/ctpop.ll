declare <4 x i32> @llvm.ctpop.v4i32(<4 x i32>)

define <4 x i32> @f(<4 x i32> %a) {
    %b = or <4 x i32> %a, <i32 0, i32 255, i32 65535, i32 16777215>
    %c = call <4 x i32> @llvm.ctpop.v4i32(<4 x i32> %b)
    %d = sub <4 x i32> splat (i32 7), %c
    %e = mul <4 x i32> %d, splat (i32 3)
    ret <4 x i32> %e
}