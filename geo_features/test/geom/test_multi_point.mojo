from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index

from geo_features.test.pytest import MojoTest
from geo_features.geom import (
    Point,
    Point2,
    PointZ,
    PointM,
    PointZM,
)
from geo_features.geom import MultiPoint
from geo_features.test.constants import lat, lon, height, measure


fn main() raises:
    test_multi_point()


fn test_multi_point() raises:
    test_constructors()
    test_mem_layout()
    test_get_item()
    test_equality_ops()
    test_is_empty()
    test_repr()
    test_str()
    test_wkt()
    test_json()
    test_from_json()
    test_from_wkt()


fn test_constructors() raises:
    var test = MojoTest("variadic list constructor")

    let mpt = MultiPoint(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    test.assert_true(mpt[0] == Point2(lon, lat), "variadic list constructor")
    test.assert_true(mpt[1] == Point2(lon, lat), "variadic list constructor")
    test.assert_true(mpt[2] == Point2(lon, lat + 1), "variadic list constructor")
    test.assert_true(mpt.__len__() == 3, "variadic list constructor")

    test = MojoTest("vector constructor")

    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    _ = MultiPoint[dims = Point2.simd_dims, dtype = Point2.dtype](points_vec)

    test = MojoTest("non power of two dims constructor")
    let mpt_z = MultiPoint[dims=3, point_simd_dims=4](
        PointZ(lon, lat, height), 
        PointZ(lon, lat + 1, height + 5),
        PointZ(lon, lat + 2, height + 6),
        PointZ(lon, lat + 3, height + 9),
    )
    test.assert_true(mpt_z[0] == PointZ(lon, lat, height), "non power of two dims constructor/0")
    test.assert_true(mpt_z[1] == PointZ(lon, lat + 1, height + 5), "non power of two dims constructor/1")
    test.assert_true(mpt_z[2] == PointZ(lon, lat + 2, height + 6), "non power of two dims constructor/2")
    test.assert_true(mpt_z.__len__() == 4, "non power of two dims constructor/len")

    let mpt_m = MultiPoint[dims=3, point_simd_dims=4](
        PointM(lon, lat, measure), 
        PointM(lon, lat + 1, measure + 5),
        PointM(lon, lat + 2, measure + 6),
        PointM(lon, lat + 3, measure + 9),
    )
    test.assert_true(mpt_z[0] == PointM(lon, lat, height), "non power of two dims constructor/0")
    test.assert_true(mpt_z[1] == PointM(lon, lat + 1, height + 5), "non power of two dims constructor/1")
    test.assert_true(mpt_z[2] == PointM(lon, lat + 2, height + 6), "non power of two dims constructor/2")
    test.assert_true(mpt_z.__len__() == 4, "non power of two dims constructor/len")

   let mpt_zm = MultiPoint[dims=4, point_simd_dims=4](
        PointZM(lon, lat, height, measure), 
        PointZM(lon, lat + 1, height + 3, measure + 5),
        PointZM(lon, lat + 2, height + 2, measure + 6),
        PointZM(lon, lat + 3, height + 1, measure + 9),
    )
    test.assert_true(mpt_zm[0] == PointZM(lon, lat, height, measure), "non power of two dims constructor/0")
    test.assert_true(mpt_zm[1] == PointZM(lon, lat + 1, height + 3, measure + 5), "non power of two dims constructor/1")
    test.assert_true(mpt_zm[2] == PointZM(lon, lat + 2, height + 2, measure + 6), "non power of two dims constructor/2")
    test.assert_true(mpt_zm.__len__() == 4, "non power of two dims constructor/len")

fn test_mem_layout() raises:
    """
    Test if MultiPoint fills the Layout struct correctly.
    """
    let test = MojoTest("mem layout")

    # equality check each point by indexing into the MultiPoint.
    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let mpt2 = MultiPoint[dims = Point2.simd_dims, dtype = Point2.dtype](points_vec)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        test.assert_true(mpt2[n] == expect_pt, "test_mem_layout")

    let layout = mpt2.data

    # offsets fields are empty in MultiPoint because of using geo_arrows "struct coordinate representation"
    test.assert_true(
        layout.geometry_offsets.num_elements() == 0, "geo_arrow geometry_offsets"
    )
    test.assert_true(layout.part_offsets.num_elements() == 0, "geo_arrow part_offsets")
    test.assert_true(layout.ring_offsets.num_elements() == 0, "geo_arrow ring_offsets")


fn test_get_item() raises:
    let test = MojoTest("get_item")
    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let mpt = MultiPoint(points_vec)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = mpt[n]
        test.assert_true(got_pt == expect_pt, "get_item")


fn test_equality_ops() raises:
    let test = MojoTest("equality operators")

    # partial simd_load (n - i < nelts)
    let mpt1 = MultiPoint(
        Point2(1, 2), Point2(3, 4), Point2(5, 6), Point2(7, 8), Point2(9, 10)
    )
    let mpt2 = MultiPoint(
        Point2(1.1, 2.1),
        Point2(3.1, 4.1),
        Point2(5.1, 6.1),
        Point2(7.1, 8.1),
        Point2(9.1, 10.1),
    )
    test.assert_true(mpt1 != mpt2, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    alias Point2F32 = Point[2, DType.float32]
    let mpt5 = MultiPoint(
        Point2F32(1, 2),
        Point2F32(5, 6),
        Point2F32(10, 11),
    )
    let mpt6 = MultiPoint(
        Point2F32(1, 2),
        Point2F32(5, 6),
        Point2F32(10, 11.1),
    )
    test.assert_true(mpt5 != mpt6, "partial simd_load (n - i < nelts) (b)")

    alias Point2F16 = Point[2, DType.float16]
    let mpt7 = MultiPoint(
        Point2F16(1, 2),
        Point2F16(5, 6),
        Point2F16(10, 11),
    )
    let mpt8 = MultiPoint(
        Point2F16(1, 2),
        Point2F16(5, 6),
        Point2F16(10, 11.1),
    )
    test.assert_true(mpt7 != mpt8, "__ne__")

    var points_vec2 = DynamicVector[Point2](10)
    for n in range(10):
        points_vec2.push_back(Point2(lon + n, lat - n))
    let mpt9 = MultiPoint(points_vec2)
    let mpt10 = MultiPoint(points_vec2)
    test.assert_true(mpt9 == mpt10, "__eq__")
    test.assert_true(mpt9 != mpt2, "__ne__")

    let mpt11 = MultiPoint(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    let mpt12 = MultiPoint(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    test.assert_true(mpt11 == mpt12, "__eq__")
    test.assert_true(mpt9 != mpt12, "__ne__")


fn test_is_empty() raises:
    let test = MojoTest("is_empty")
    let empty_mpt = MultiPoint()
    test.assert_true(empty_mpt.is_empty() == True, "is_empty()")


fn test_repr() raises:
    let test = MojoTest("__repr__")
    let mpt = MultiPoint(Point2(lon, lat), Point2(lon + 1, lat + 1))
    let s = mpt.__repr__()
    test.assert_true(s == "MultiPoint[2, float64](2 points)", "__repr__")


fn test_str() raises:
    let test = MojoTest("__str__")
    let mpt = MultiPoint(Point2(lon, lat), Point2(lon + 1, lat + 1))
    test.assert_true(mpt.__str__() == mpt.wkt(), "__str__")


fn test_wkt() raises:
    let test = MojoTest("wkt")
    let mp = MultiPoint(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    test.assert_true(
        mp.wkt()
        == "MULTIPOINT(-108.68000000000001 38.973999999999997, -108.68000000000001"
        " 38.973999999999997, -108.68000000000001 39.973999999999997)",
        "wkt",
    )


fn test_json() raises:
    let test = MojoTest("json")
    let mpt = MultiPoint(Point2(lon, lat), Point2(lon + 1, lat + 1))
    test.assert_true(
        mpt.json()
        == '{"type":"MultiPoint","coordinates":[[-108.68000000000001,38.973999999999997],[-107.68000000000001,39.973999999999997]]}',
        "json",
    )


fn test_from_json() raises:
    let test = MojoTest("from_json (⚠️  not implemented)")
    let json_str = String(
        '{"type":"MultiPoint","coordinates":[[42.0,38.9739990234375],[42.0,38.9739990234375]]}'
    )
    let json = Python.import_module("orjson")
    let json_dict = json.loads(json_str)

    try:
        _ = MultiPoint.from_json(json_dict)
        raise Error("unreachable")
    except e:
        test.assert_true(
            e.__str__() == "not implemented", "unexpected error value"
        )  # TODO


fn test_from_wkt() raises:
    let test = MojoTest("from_wkt (⚠️  not implemented)")
    # try:
    #     _ = MultiPoint.from_wkt("")
    #     raise Error("unreachable")
    # except e:
    #     test.assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO
