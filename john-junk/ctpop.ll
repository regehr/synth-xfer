declare <4 x i32> @llvm.ctpop.v4i32(<4 x i32>)

define <4 x i32> @f(<4 x i32> %a) {
    %b = or <4 x i32> %a, <i32 0, i32 3, i32 15, i32 255>
    %c = call <4 x i32> @llvm.ctpop.v4i32(<4 x i32> %b)
    %d = and <4 x i32> %c, splat (i32 1)
    %e = add <4 x i32> %d, splat (i32 -1)
    ret <4 x i32> %e
}