from pathlib import Path

PROJ_DIR = Path(__file__).parent.parent
DATA_DIR = PROJ_DIR / "tests" / "data"


def test_files():
    "Users must have these files on their system for our tool to work"

    assert (PROJ_DIR / "mlir").is_dir()
    assert (PROJ_DIR / "mlir" / "KnownBits").is_dir()
    assert (PROJ_DIR / "mlir" / "UConstRange").is_dir()
    assert (PROJ_DIR / "mlir" / "SConstRange").is_dir()
    assert (PROJ_DIR / "mlir" / "Operations").is_dir()
    assert (PROJ_DIR / "mlir" / "Operations" / "And.mlir").is_file()
    assert (PROJ_DIR / "mlir" / "Operations" / "Or.mlir").is_file()
    assert (PROJ_DIR / "mlir" / "Operations" / "Xor.mlir").is_file()
    assert (PROJ_DIR / "mlir" / "Operations" / "Add.mlir").is_file()
    assert DATA_DIR.is_dir()
