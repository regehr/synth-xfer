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
    lowerer_4.add_fn(kb_and_mlir, shim=True)
    assert str(lowerer_4) == (DATA_DIR / "kb_and_4.ll").read_text()

    lowerer_4 = LowerToLLVM(4)
    lowerer_4.add_fn(kb_or_mlir, shim=True)
    assert str(lowerer_4) == (DATA_DIR / "kb_or_4.ll").read_text()

    lowerer_4 = LowerToLLVM(4)
    lowerer_4.add_fn(kb_xor_mlir, shim=True)
    assert str(lowerer_4) == (DATA_DIR / "kb_xor_4.ll").read_text()

    lowerer_4 = LowerToLLVM(4)
    lowerer_4.add_fn(cr_add_mlir, shim=True)
    assert str(lowerer_4) == (DATA_DIR / "cr_add_4.ll").read_text()


def test_conc_lowering():
    conc_and_f = PROJ_DIR / "mlir" / "Operations" / "And.mlir"
    conc_add_f = PROJ_DIR / "mlir" / "Operations" / "Add.mlir"

    lowerer = LowerToLLVM(4)
    and_kb_helpers = get_helper_funcs(conc_and_f, AbstractDomain.KnownBits)
    lowerer.add_fn(and_kb_helpers.meet_func)
    lowerer.add_fn(and_kb_helpers.get_top_func)
    lowerer.add_fn(and_kb_helpers.crt_func, shim=True)
    assert str(lowerer) == (DATA_DIR / "kb_and_helpers_4.ll").read_text()

    lowerer = LowerToLLVM(4)
    add_ucr_helpers = get_helper_funcs(conc_add_f, AbstractDomain.UConstRange)
    lowerer.add_fn(add_ucr_helpers.meet_func)
    lowerer.add_fn(add_ucr_helpers.get_top_func)
    lowerer.add_fn(add_ucr_helpers.crt_func, shim=True)
    assert str(lowerer) == (DATA_DIR / "cr_add_helpers_4.ll").read_text()
