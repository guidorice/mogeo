from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index

from geo_features.geom.layout import Layout, Layout2, Layout3, Layout4
from geo_features.test.helpers import assert_true
from geo_features.test.constants import lat, lon, height, measure


fn main() raises:
    test_memory_layout()


fn test_memory_layout() raises:
    test_constructors()
    test_equality_ops()
    test_len()

    print()


fn test_constructors() raises:
    print("# constructors")
    var n = 10

    # 2x10
    let layout_a = Layout2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    var shape = layout_a.coordinates.shape()
    assert_true(shape[0] == 2, "constructor")
    assert_true(shape[1] == n, "constructor")

    # 3x15
    n = 15
    let layout_b = Layout3(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    shape = layout_b.coordinates.shape()
    assert_true(shape[0] == 3, "constructor")
    assert_true(shape[1] == n, "constructor")

    # 4x20
    n = 20
    let layout_c = Layout4(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    shape = layout_c.coordinates.shape()
    assert_true(shape[0] == 4, "constructor")
    assert_true(shape[1] == n, "constructor")


fn test_equality_ops() raises:
    print("# equality ops")

    let n = 20
    var ga2 = Layout2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    var ga2b = Layout2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    for dim in range(0, 2):
        for coord in range(0, n):
            let idx = Index(dim, coord)
            ga2.coordinates[idx] = 42.0
            ga2b.coordinates[idx] = 42.0
    assert_true(ga2 == ga2b, "__eq__")

    ga2.coordinates[Index(0, n - 1)] = 3.14
    assert_true(ga2 != ga2b, "__ne__")


fn test_len() raises:
    print("# len")
    let n = 50
    let ga1 = Layout2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    let l = ga1.__len__()
    assert_true(l == 50, "__len__")
