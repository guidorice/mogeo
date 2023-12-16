from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index
from pathlib import Path

from geo_features.test.constants import lat, lon, height, measure
from geo_features.test.pytest import MojoTest
from geo_features.geom.point import Point, Point64
from geo_features.geom.multi_point import MultiPoint
from geo_features.serialization.json import JSONParser
from geo_features.geom.enums import CoordDims


fn main() raises:
    test_multi_point()


fn test_multi_point() raises:
    test_constructors()
    test_mem_layout()
    test_get_item()
    test_equality_ops()
    test_is_empty()
    test_repr()
    test_stringable()
    test_wktable()
    test_jsonable()


fn test_constructors() raises:
    var test = MojoTest("variadic list constructor")

    let mpt = MultiPoint(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    test.assert_true(mpt[0] == Point(lon, lat), "variadic list constructor")
    test.assert_true(mpt[1] == Point(lon, lat), "variadic list constructor")
    test.assert_true(mpt[2] == Point(lon, lat + 1), "variadic list constructor")
    test.assert_true(len(mpt) == 3, "variadic list constructor")

    test = MojoTest("vector constructor")

    var points_vec = DynamicVector[Point64](10)
    for n in range(10):
        points_vec.push_back(Point(lon + n, lat - n))
    _ = MultiPoint(points_vec)


fn test_mem_layout() raises:
    """
    Test if MultiPoint fills the Layout struct correctly.
    """
    let test = MojoTest("mem layout")

    # equality check each point by indexing into the MultiPoint.
    var points_vec = DynamicVector[Point64](10)
    for n in range(10):
        points_vec.push_back(Point(lon + n, lat - n))
    let mpt2 = MultiPoint(points_vec)
    for n in range(10):
        let expect_pt = Point(lon + n, lat - n)
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
    var points_vec = DynamicVector[Point64](10)
    for n in range(10):
        points_vec.push_back(Point(lon + n, lat - n))
    let mpt = MultiPoint(points_vec)
    for n in range(10):
        let expect_pt = Point(lon + n, lat - n)
        let got_pt = mpt[n]
        test.assert_true(got_pt == expect_pt, "get_item")


fn test_equality_ops() raises:
    let test = MojoTest("equality operators")

    # partial simd_load (n - i < nelts)
    let mpt1 = MultiPoint(
        Point(1, 2), Point(3, 4), Point(5, 6), Point(7, 8), Point(9, 10)
    )
    let mpt2 = MultiPoint(
        Point(1.1, 2.1),
        Point(3.1, 4.1),
        Point(5.1, 6.1),
        Point(7.1, 8.1),
        Point(9.1, 10.1),
    )
    test.assert_true(mpt1 != mpt2, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    alias Point2F32 = Point[DType.float32]
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

    alias Point2F16 = Point[DType.float16]
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

    var points_vec2 = DynamicVector[Point64](10)
    for n in range(10):
        points_vec2.push_back(Point(lon + n, lat - n))
    let mpt9 = MultiPoint(points_vec2)
    let mpt10 = MultiPoint(points_vec2)
    test.assert_true(mpt9 == mpt10, "__eq__")
    test.assert_true(mpt9 != mpt2, "__ne__")

    let mpt11 = MultiPoint(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    let mpt12 = MultiPoint(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    test.assert_true(mpt11 == mpt12, "__eq__")
    test.assert_true(mpt9 != mpt12, "__ne__")


fn test_is_empty() raises:
    let test = MojoTest("is_empty")
    let empty_mpt = MultiPoint()
    test.assert_true(empty_mpt.is_empty() == True, "is_empty()")


fn test_repr() raises:
    let test = MojoTest("__repr__")
    let mpt = MultiPoint(Point(lon, lat), Point(lon + 1, lat + 1))
    let s = mpt.__repr__()
    test.assert_true(s == "MultiPoint [Point, float64](2 points)", "__repr__")


fn test_stringable() raises:
    let test = MojoTest("__str__")
    let mpt = MultiPoint(Point(lon, lat), Point(lon + 1, lat + 1))
    test.assert_true(mpt.__str__() == mpt.__repr__(), "__str__")


fn test_wktable() raises:
    let test = MojoTest("wktable")
    let path = Path("geo_features/test/fixtures/wkt/multi_point")
    let fixtures = VariadicList("point.wkt", "point_z.wkt")
    for i in range(len(fixtures)):
        let file = path / fixtures[i]
        with open(file.path, "r") as f:
            let wkt = f.read()
            let mp = MultiPoint.from_wkt(wkt)
            test.assert_true(
                mp.wkt() != "FIXME", "wkt"
            )  # FIXME: no number formatting so cannot compare wkt strings.


fn test_jsonable() raises:
    test_json()
    test_from_json()


fn test_json() raises:
    let test = MojoTest("json")

    let mpt = MultiPoint(Point(lon, lat), Point(lon + 1, lat + 1))
    test.assert_true(
        mpt.json()
        == '{"type":"MultiPoint","coordinates":[[-108.68000000000001,38.973999999999997],[-107.68000000000001,39.973999999999997]]}',
        "json",
    )

    let mpt_z = MultiPoint(Point(lon, lat, height), Point(lon + 1, lat + 1, height - 1))
    test.assert_true(
        mpt_z.json()
        == '{"type":"MultiPoint","coordinates":[[-108.68000000000001,38.973999999999997,8.0],[-107.68000000000001,39.973999999999997,7.0]]}',
        "json",
    )

    let expect_error = "GeoJSON only allows dimensions X, Y, and optionally Z (RFC 7946)"
    var mpt_m = MultiPoint(
        Point(lon, lat, measure), Point(lon + 1, lat + 1, measure - 1)
    )
    mpt_m.set_ogc_dims(CoordDims.PointM)
    try:
        _ = mpt_m.json()
    except e:
        test.assert_true(str(e) == expect_error, "json raises")

    let mpt_zm = MultiPoint(
        Point(lon, lat, height, measure),
        Point(lon + 1, lat + 1, height * 2, measure - 1),
    )
    try:
        _ = mpt_zm.json()
    except e:
        test.assert_true(str(e) == expect_error, "json raises")


fn test_from_json() raises:
    pass
    # let test = MojoTest("from_json")

    # let path = Path("geo_features/test/fixtures/geojson/multi_point")
    # let fixtures = VariadicList("multi_point.geojson")  # , "multi_point_z.geojson"
    # for i in range(len(fixtures)):
    #     let file = path / fixtures[i]
    #     with open(file.path, "r") as f:
    #         let json_str = f.read()
    # _ = MultiPoint.from_json(json_str)
    # let json_dict = JSONParser.parse(json_str)
    # _ = MultiPoint.from_json(json_dict)
