from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index

from benchmark import Benchmark

from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.geom.line_string import (
    LineString,
    LineString2,
    LineString3,
    LineString4,
)
from geo_features.test.helpers import assert_true

let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0


fn test_line_string() raises:
    print("# LineString\n")

    print("variadic list constructor...")
    let lstr = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(lstr[0] == Point2(lon, lat), "variadic list constructor")
    assert_true(lstr[1] == Point2(lon, lat), "variadic list constructor")
    assert_true(lstr[2] == Point2(lon, lat + 1), "variadic list constructor")
    assert_true(lstr.__len__() == 3, "variadic list constructor")
    print("✅")

    print("vector constructor...")
    var points_vec = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let lstr2 = LineString2(points_vec)
    for n in range(0, 10):
        let expect_pt = Point2(lon + n, lat - n)
        assert_true(lstr2[n] == expect_pt, "vector constructor")
    assert_true(lstr2.__len__() == 10, "vector constructor")
    print("✅")

    print("constructor raises validation error...")
    try:
        _ = LineString2(Point2(lon, lat), Point2(lon, lat))
        raise Error("unreachable")
    except e:
        pass
        # assert_true(
        #     e.__str__() == "LineStrings with exactly two identical points are invalid.",
        #     "unexpected error value",
        # )

    # try:
    #     _ = LineString2(Point2(lon, lat))
    #     raise Error("unreachable")
    # except e:
    #     assert_true(
    #         e.__str__() == "LineStrings must have either 0 or 2 or more points.",
    #         "unexpected error value",
    #     )

    # try:
    #     _ = LineString2(Point2(lon, lat), Point2(lon + 1, lat + 1), Point2(lon, lat))
    #     raise Error("unreachable")
    # except e:
    #     assert_true(
    #         e.__str__() == "LineStrings must not be closed: try LinearRing.",
    #         "unexpected error value",
    #     )
    # print("✅")

    # Test if LineString fills the GeoArrow struct correctly.
    # print("geo_arrow...")

    # # equality check each point by indexing into the MultiPoint.
    # var points_vec20 = DynamicVector[Point2](10)
    # for n in range(0, 10):
    #     points_vec20.push_back(Point2(lon + n, lat - n))
    # let lstr20 = LineString2(points_vec20)
    # for n in range(0, 10):
    #     let expect_pt = Point2(lon + n, lat - n)
    #     assert_true(lstr20[n] == expect_pt, "geo_arrow")

    # let arrow = lstr20.data

    # assert_true(arrow.geometry_offsets.size > 0, "geo_arrow geometry_offsets")
    # assert_true(arrow.part_offsets.size > 0, "geo_arrow part_offsets")
    # assert_true(arrow.ring_offsets.size > 0, "geo_arrow ring_offsets")

    # print("✅")


    print("get_item...")
    for n in range(0, 10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = lstr2[n]
        assert_true(got_pt == expect_pt, "get_item")
    print("✅")

    print("equality operators...")

    # partial simd_load (n - i < nelts)
    let lstr8 = LineString2(
        Point2(1, 2), Point2(3, 4), Point2(5, 6), Point2(7, 8), Point2(9, 10)
    )
    let lstr9 = LineString2(
        Point2(1.1, 2.1),
        Point2(3.1, 4.1),
        Point2(5.1, 6.1),
        Point2(7.1, 8.1),
        Point2(9.1, 10.1),
    )
    assert_true(lstr8 != lstr9, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    let lstr10 = LineString[DType.float32, 2](
        Point[DType.float32, 2](1, 2),
        Point[DType.float32, 2](5, 6),
        Point[DType.float32, 2](10, 11),
    )
    let lstr11 = LineString[DType.float32, 2](
        Point[DType.float32, 2](1, 2),
        Point[DType.float32, 2](5, 6),
        Point[DType.float32, 2](10, 11.1),
    )
    assert_true(lstr10 != lstr11, "partial simd_load (n - i < nelts) (b)")

    let lstr12 = LineString[DType.float16, 2](
        Point[DType.float16, 2](1, 2),
        Point[DType.float16, 2](5, 6),
        Point[DType.float16, 2](10, 11),
    )
    let lstr13 = LineString[DType.float16, 2](
        Point[DType.float16, 2](1, 2),
        Point[DType.float16, 2](5, 6),
        Point[DType.float16, 2](10, 11.1),
    )
    assert_true(lstr10 != lstr11, "__ne__")

    var points_vec2 = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec2.push_back(Point2(lon + n, lat - n))
    let lstr3 = LineString2(points_vec2)
    assert_true(lstr2 == lstr3, "lstr2 == lstr3")

    let lstr4 = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(lstr == lstr4, "lstr == lstr4")

    let lstr5 = LineString2(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr4 != lstr5, "(lstr4 != lstr5")
    print("✅")

    print("is_empty...")
    let empty_lstr = LineString2()
    _ = empty_lstr.is_empty()
    print("✅")

    print("__repr__...")
    let s = lstr5.__repr__()
    assert_true(s == "LineString[float32, 2](2 points)", "__repr__")
    print("✅")

    print("__str__...")
    assert_true(lstr5.__str__() == lstr5.wkt(), "__str__")
    print("✅")

    print("wkt...")
    let try_wkt = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(
        try_wkt.wkt()
        == "LINESTRING(-108.68000030517578 38.9739990234375, -108.68000030517578"
        " 38.9739990234375, -108.68000030517578 39.9739990234375)",
        "wkt",
    )
    print("✅")

    print("json...")
    assert_true(
        lstr2.json()
        == '{"type":"LineString","coordinates":[[-108.68000030517578,38.9739990234375],[-107.68000030517578,37.9739990234375],[-106.68000030517578,36.9739990234375],[-105.68000030517578,35.9739990234375],[-104.68000030517578,34.9739990234375],[-103.68000030517578,33.9739990234375],[-102.68000030517578,32.9739990234375],[-101.68000030517578,31.974000930786133],[-100.68000030517578,30.974000930786133],[-99.680000305175781,29.974000930786133]]}',
        "json",
    )
    print("✅")

    # print("is_simple (⚠️  not implemented)")
    # try:
    #     _ = lstr5.is_simple()
    #     raise Error("unreachable")
    # except e:
    #     assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO

    # print("from_json (⚠️  not implemented)")
    # let json_str = String(
    #     '{"type":"LineString","coordinates":[[42.0,38.9739990234375],[42.0,38.9739990234375]]}'
    # )
    # let json = Python.import_module("json")
    # let json_dict = json.loads(json_str)

    # try:
    #     _ = LineString2.from_json(json_dict)
    #     raise Error("unreachable")
    # except e:
    #     assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO

    # print("from_wkt (⚠️  not implemented)")
    # try:
    #     _ = LineString2.from_wkt("")
    #     raise Error("unreachable")
    # except e:
    #     assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO

    # print()
