import testing
from pathlib import Path
from python import Python

fn assert_true(cond: Bool, message: String) raises:
    """
    Wraps testing.assert_true, raises Error on assertion failure.
    """
    if not testing.assert_true(cond, message):

        raise Error(message)


fn load_geoarrow_test_fixture(path: Path) raises -> PythonObject:
    """
    Reads the geoarrow test data fixture at path.

    Returns
    -------
    table : pyarrow.Table
        The contents of the Feather file as a pyarrow.Table
    """
    let feather = Python.import_module("pyarrow.feather")
    let table = feather.read_table(PythonObject(path.__str__()))
    return table
