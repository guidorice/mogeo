from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index

from geo_features.test.pytest import MojoTest
from geo_features.geom.layout import Layout
from geo_features.test.constants import lat, lon, height, measure
from geo_features.geom.enums import CoordDims

fn main() raises:
    test_constructors()
    test_equality_ops()
    test_len()
    test_dims()


fn test_constructors() raises:
    let test = MojoTest("constructors")

    var n = 10

    # 2x10 (default of 2 dims)
    let layout_a = Layout(coords_size=n)
    var shape = layout_a.coordinates.shape()
    test.assert_true(shape[0] == 2, "2x10 constructor")
    test.assert_true(shape[1] == n, "2x10 constructor")

    # 3x15
    n = 15
    let layout_b = Layout(ogc_dims=CoordDims.PointZ, coords_size=n)
    shape = layout_b.coordinates.shape()
    test.assert_true(shape[0] == 3, "3x15 constructor")
    test.assert_true(shape[1] == n, "3x15 constructor")

    # 4x20
    n = 20
    let layout_c = Layout(ogc_dims=CoordDims.PointZM, coords_size=n)
    shape = layout_c.coordinates.shape()
    test.assert_true(shape[0] == 4, "4x20 constructor")
    test.assert_true(shape[1] == n, "4x20 constructor")


fn test_equality_ops() raises:
    let test = MojoTest("equality ops")

    let n = 20
    var ga2 = Layout(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    var ga2b = Layout(coords_size=n, geoms_size=0, parts_size=0, rings_size=0)
    for dim in range(2):
        for coord in range(n):
            let idx = Index(dim, coord)
            ga2.coordinates[idx] = 42.0
            ga2b.coordinates[idx] = 42.0
    test.assert_true(ga2 == ga2b, "__eq__")

    ga2.coordinates[Index(0, n - 1)] = 3.14
    test.assert_true(ga2 != ga2b, "__ne__")

fn test_len() raises:
    let test = MojoTest("__len__")

    let n = 50
    let l = Layout(coords_size=n)
    test.assert_true(len(l) == 50, "__len__")

fn test_dims() raises:
    let test = MojoTest("dims")
    let l = Layout(coords_size=10)
    let expect_dims = len(CoordDims.Point)
    test.assert_true(l.dims() == expect_dims, "dims")
