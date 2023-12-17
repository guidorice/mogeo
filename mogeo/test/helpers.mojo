import testing
from pathlib import Path
from python import Python


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
