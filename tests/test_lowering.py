from pathlib import Path

from synth_xfer._util.domain import AbstractDomain
from synth_xfer._util.lower import LowerToLLVM
from synth_xfer._util.parse_mlir import get_helper_funcs, parse_mlir_func

PROJ_DIR = Path(__file__).parent.parent
DATA_DIR = PROJ_DIR / "tests" / "data"


def test_xfer_lowering():
    kb_and_mlir = parse_mlir_func(DATA_DIR / "kb_and.mlir")
    kb_or_mlir = parse_mlir_func(DATA_DIR / "kb_or.mlir")
    kb_xor_mlir = parse_mlir_func(DATA_DIR / "kb_xor.mlir")
    cr_add_mlir = parse_mlir_func(DATA_DIR / "cr_add.mlir")

    lowerer_4 = LowerToLLVM(4)

    kb_and_4 = lowerer_4.add_fn(kb_and_mlir, None, False)
    kb_and_4_shim = lowerer_4.shim_xfer(kb_and_4)
    assert str(kb_and_4) == (DATA_DIR / "kb_and_4.ll").read_text()
    assert str(kb_and_4_shim) == (DATA_DIR / "kb_and_4_shim.ll").read_text()

    kb_or_4 = lowerer_4.add_fn(kb_or_mlir, None, False)
    kb_or_4_shim = lowerer_4.shim_xfer(kb_or_4)
    assert str(kb_or_4) == (DATA_DIR / "kb_or_4.ll").read_text()
    assert str(kb_or_4_shim) == (DATA_DIR / "kb_or_4_shim.ll").read_text()

    kb_xor_4 = lowerer_4.add_fn(kb_xor_mlir, None, False)
    kb_xor_4_shim = lowerer_4.shim_xfer(kb_xor_4)
    assert str(kb_xor_4) == (DATA_DIR / "kb_xor_4.ll").read_text()
    assert str(kb_xor_4_shim) == (DATA_DIR / "kb_xor_4_shim.ll").read_text()

    cr_add_4 = lowerer_4.add_fn(cr_add_mlir, None, False)
    cr_add_4_shim = lowerer_4.shim_xfer(cr_add_4)
    assert str(cr_add_4) == (DATA_DIR / "cr_add_4.ll").read_text()
    assert str(cr_add_4_shim) == (DATA_DIR / "cr_add_4_shim.ll").read_text()

    lowerer_64 = LowerToLLVM(64)

    kb_and_64 = lowerer_64.add_fn(kb_and_mlir, None, False)
    kb_and_64_shim = lowerer_64.shim_xfer(kb_and_64)
    print(kb_and_64)
    print(kb_and_64_shim)
    assert str(kb_and_64) == (DATA_DIR / "kb_and_64.ll").read_text()
    assert str(kb_and_64_shim) == (DATA_DIR / "kb_and_64_shim.ll").read_text()

    kb_or_64 = lowerer_64.add_fn(kb_or_mlir, None, False)
    kb_or_64_shim = lowerer_64.shim_xfer(kb_or_64)
    print(kb_or_64)
    print(kb_or_64_shim)
    assert str(kb_or_64) == (DATA_DIR / "kb_or_64.ll").read_text()
    assert str(kb_or_64_shim) == (DATA_DIR / "kb_or_64_shim.ll").read_text()

    kb_xor_64 = lowerer_64.add_fn(kb_xor_mlir, None, False)
    kb_xor_64_shim = lowerer_64.shim_xfer(kb_xor_64)
    assert str(kb_xor_64) == (DATA_DIR / "kb_xor_64.ll").read_text()
    assert str(kb_xor_64_shim) == (DATA_DIR / "kb_xor_64_shim.ll").read_text()

    cr_add_64 = lowerer_64.add_fn(cr_add_mlir, None, False)
    cr_add_64_shim = lowerer_64.shim_xfer(cr_add_64)
    assert str(cr_add_64) == (DATA_DIR / "cr_add_64.ll").read_text()
    assert str(cr_add_64_shim) == (DATA_DIR / "cr_add_64_shim.ll").read_text()


def test_conc_lowering():
    conc_and_f = PROJ_DIR / "mlir" / "Operations" / "And.mlir"
    conc_add_f = PROJ_DIR / "mlir" / "Operations" / "Add.mlir"

    lowerer = LowerToLLVM(4)
    and_kb_helpers = get_helper_funcs(conc_and_f, AbstractDomain.KnownBits)
    kb_meet_4 = lowerer.add_fn(and_kb_helpers.meet_func)
    kb_top_4 = lowerer.add_fn(and_kb_helpers.get_top_func)
    assert str(kb_meet_4) == (DATA_DIR / "kb_meet_4.ll").read_text()
    assert str(kb_top_4) == (DATA_DIR / "kb_top_4.ll").read_text()

    conc_and_mlir = and_kb_helpers.crt_func
    conc_and_4 = lowerer.add_fn(conc_and_mlir)
    conc_and_4_shim = lowerer.shim_conc(conc_and_4)
    assert str(conc_and_4) == (DATA_DIR / "concrete_and_4.ll").read_text()
    assert str(conc_and_4_shim) == (DATA_DIR / "concrete_and_4_shim.ll").read_text()

    lowerer = LowerToLLVM(4)
    add_ucr_helpers = get_helper_funcs(conc_add_f, AbstractDomain.UConstRange)
    ucr_meet_4 = lowerer.add_fn(add_ucr_helpers.meet_func)
    ucr_top_4 = lowerer.add_fn(add_ucr_helpers.get_top_func)
    assert str(ucr_meet_4) == (DATA_DIR / "ucr_meet_4.ll").read_text()
    assert str(ucr_top_4) == (DATA_DIR / "ucr_top_4.ll").read_text()

    conc_add_mlir = add_ucr_helpers.crt_func
    conc_add_4 = lowerer.add_fn(conc_add_mlir)
    conc_add_4_shim = lowerer.shim_conc(conc_add_4)
    assert str(conc_add_4) == (DATA_DIR / "concrete_add_4.ll").read_text()
    assert str(conc_add_4_shim) == (DATA_DIR / "concrete_add_4_shim.ll").read_text()
