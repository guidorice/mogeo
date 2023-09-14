# from testing import assert_true, assert_false
from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index

from benchmark import Benchmark

from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.geom.line_string import LineString, LineString2, LineString3, LineString4
from geo_features.test.helpers import assert_true, assert_false

let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0

def test_line_string():
    print("# LineString\n")

    print("variadic list constructor...")
    let lstr = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat+1))
    assert_true(lstr.__len__() == 3, "variadic list constructor")
    print("✅")

    print("vector constructor...")
    var points_vec = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec.push_back( Point2(lon + n, lat - n) )
    let lstr2 = LineString2(points_vec)
    assert_true(lstr2.__len__() == 10, "vector constructor")
    print("✅")

    print("constructor raises validation error...")
    try:
        _ = LineString2(Point2(lon, lat), Point2(lon, lat))
        raise Error("unreachable")
    except e:
        assert_true(e.value == "LineStrings with exactly two identical points are invalid.", "unexpected error value")

    try:
        _ = LineString2(Point2(lon, lat))
        raise Error("unreachable")
    except e:
        assert_true(e.value == "LineStrings must have either 0 or 2 or more points.", "unexpected error value")

    try:
        _ = LineString2(Point2(lon, lat), Point2(lon+1, lat+1), Point2(lon, lat))
        raise Error("unreachable")
    except e:
        assert_true(e.value == "LineStrings must not be closed: see LinearRing.", "unexpected error value")
    print("✅")

    print("get_item...")
    for n in range(0, 10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = lstr2[n]
        assert_true(got_pt == expect_pt, "lstr2 == expect_pt")
    print("✅")

    print("equality operators...")

    # partial simd_load (n - i < nelts)
    let lstr8 = LineString2(Point2(1,2),     Point2(3,4),     Point2(5, 6),     Point2(7, 8), Point2(9, 10))
    let lstr9 = LineString2(Point2(1.1,2.1), Point2(3.1,4.1), Point2(5.1, 6.1), Point2(7.1, 8.1), Point2(9.1, 10.1))
    assert_true(lstr8 != lstr9, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    let lstr10 = LineString[DType.float32, 2](Point[DType.float32, 2](1,2), Point[DType.float32, 2](5,6), Point[DType.float32, 2](10,11))
    let lstr11 = LineString[DType.float32, 2](Point[DType.float32, 2](1,2), Point[DType.float32, 2](5,6), Point[DType.float32, 2](10,11.1))
    assert_true(lstr10 != lstr11, "partial simd_load (n - i < nelts) (b)")

    let lstr12 = LineString[DType.float16, 2](Point[DType.float16, 2](1,2), Point[DType.float16, 2](5,6), Point[DType.float16, 2](10,11))
    let lstr13 = LineString[DType.float16, 2](Point[DType.float16, 2](1,2), Point[DType.float16, 2](5,6), Point[DType.float16, 2](10,11.1))
    assert_true(lstr10 != lstr11, "__ne__")

    var points_vec2 = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec2.push_back(Point2(lon + n, lat - n))
    let lstr3 = LineString2(points_vec2)
    assert_true(lstr2 == lstr3, "lstr2 == lstr3")

    let lstr4 = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat+1))
    assert_true(lstr == lstr4, "lstr == lstr4")

    let lstr5 = LineString2(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr4 != lstr5, "(lstr4 != lstr5")
    print("✅")

    print("is_empty...")
    let empty_lstr = LineString2()
    _ = empty_lstr.is_empty()
    print("✅")

     print("__repr__...")
    var s = lstr5.__repr__()
    assert_true(s == "LineString[float32, 2](2 points)", "__repr__")
    print("✅")

    print("__str__...")
    assert_true(
        lstr5.__str__() == lstr5.wkt(),
        "__str__"
    )
    print("✅")

    print("wkt...")
    let try_wkt = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat+1))
    assert_true(
        try_wkt.wkt() == 
        "LINESTRING(-108.68000030517578 38.9739990234375, -108.68000030517578 38.9739990234375, -108.68000030517578 39.9739990234375)",
        "wkt")
    print("✅")

    print("json...")
    s = lstr5.json()
    assert_true(
        lstr5.json()
        ==
        '{"type":"LineString","coordinates":[[42.0,38.9739990234375],[42.0,38.9739990234375]]}',
        "json"
    )
    print("✅")

    print("is_simple... (⚠️  not implemented)")
    try:
        lstr5.is_simple()
        raise Error("unreachable")
    except e:
        assert_true(e.value == "not implemented", "unexpected error value")  # TODO
    print("✅")

    print("from_json...(⚠️  not implemented)")
    let json_str = String('{"type":"LineString","coordinates":[[42.0,38.9739990234375],[42.0,38.9739990234375]]}')
    let json = Python.import_module("json")
    let json_dict = json.loads(json_str)

    try:
        _ = LineString2.from_json(json_dict)
        raise Error("unreachable")
    except e:
        assert_true(e.value == "not implemented", "unexpected error value")  # TODO
    print("✅")

    print("from_wkt...(⚠️  not implemented)")
    try:
        _ = LineString2.from_wkt("")
        raise Error("unreachable")
    except e:
        assert_true(e.value == "not implemented", "unexpected error value")  # TODO
