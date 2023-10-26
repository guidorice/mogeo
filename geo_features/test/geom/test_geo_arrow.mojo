from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index

from geo_features.geom import GeoArrow, GeoArrow2, GeoArrow3, GeoArrow4
from geo_features.test.helpers import assert_true
from geo_features.test.constants import lat, lon, height, measure


fn main() raises:
    test_geo_arrow()


fn test_geo_arrow() raises:
    print("# GeoArrow\n")

    test_constructors()
    test_len()
    test_equality_ops()

    print()


fn test_constructors() raises:
    print("constructors...")
    var n = 10

    let ga2 = GeoArrow2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    var shape = ga2.coordinates.shape()
    assert_true(shape[0] == 2, "constructor")
    assert_true(shape[1] == n, "constructor")

    n = 15
    let ga3 = GeoArrow3(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    shape = ga3.coordinates.shape()
    assert_true(shape[0] == 3, "constructor")
    assert_true(shape[1] == n, "constructor")

    n = 20
    let ga4 = GeoArrow4(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    shape = ga4.coordinates.shape()
    assert_true(shape[0] == 4, "constructor")
    assert_true(shape[1] == n, "constructor")

    print("✅")


fn test_equality_ops() raises:
    print("equality ops...")

    let n = 20
    var ga2 = GeoArrow2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    var ga2b = GeoArrow2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    for dim in range(0, 2):
        for coord in range(0, n):
            let idx = Index(dim, coord)
            ga2.coordinates[idx] = 42.0
            ga2b.coordinates[idx] = 42.0
    assert_true(ga2 == ga2b, "__eq__")

    ga2.coordinates[Index(0, n - 1)] = 3.14
    assert_true(ga2 != ga2b, "__ne__")

    print("✅")


fn test_len() raises:
    print("len...")
    let n = 50
    let ga1 = GeoArrow2(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    let l = ga1.__len__()
    assert_true(l == 50, "__len__")
    print("✅")
