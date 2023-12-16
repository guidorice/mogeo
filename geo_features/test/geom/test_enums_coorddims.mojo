from python import Python
from python.object import PythonObject
from pathlib import Path

from geo_features.geom.empty import empty_value, is_empty
from geo_features.test.pytest import MojoTest
from geo_features.geom.enums import CoordDims


fn main() raises:
    test_coord_dims()


fn test_coord_dims() raises:
    test_constructors()
    test_str()
    test_eq()
    test_getters()
    test_len()


fn test_constructors():
    let test = MojoTest("constructors")
    _ = CoordDims(42)


fn test_len():
    let test = MojoTest("len")

    let n = 42
    let pt = CoordDims(n)
    test.assert_true(len(pt) == n, "dims()")


fn test_getters():
    let test = MojoTest("getters")
    let pt = CoordDims.Point
    test.assert_true(not pt.has_height(), "has_height")
    test.assert_true(not pt.has_measure(), "has_measure")

    let pt_z = CoordDims.PointZ
    test.assert_true(pt_z.has_height(), "has_height")
    test.assert_true(not pt_z.has_measure(), "has_measure")

    let pt_m = CoordDims.PointM
    test.assert_true(pt_m.has_measure(), "has_height")
    test.assert_true(not pt_m.has_height(), "has_measure")

    let pt_zm = CoordDims.PointZM
    test.assert_true(pt_zm.has_measure(), "has_height")
    test.assert_true(pt_zm.has_height(), "has_measure")


fn test_str() raises:
    let test = MojoTest("__str__")

    let pt = CoordDims.Point
    test.assert_true(str(pt) == "Point", "__str__")

    let pt_z = CoordDims.PointZ
    test.assert_true(str(pt_z) == "Point Z", "__str__")

    let pt_m = CoordDims.PointM
    test.assert_true(str(pt_m) == "Point M", "__str__")

    let pt_zm = CoordDims.PointZM
    test.assert_true(str(pt_zm) == "Point ZM", "__str__")

    let pt_nd = CoordDims.PointND
    test.assert_true(str(pt_nd) == "Point ND", "__str__")


fn test_eq() raises:
    let test = MojoTest("__eq__, __ne__")

    let pt = CoordDims.Point
    let pt_z = CoordDims.PointZ
    test.assert_true(pt != pt_z, "__ne__")

    let n = 42
    let pt_nd_a = CoordDims(n)
    let pt_nd_b = CoordDims(n)
    test.assert_true(pt_nd_a == pt_nd_b, "__eq__")
