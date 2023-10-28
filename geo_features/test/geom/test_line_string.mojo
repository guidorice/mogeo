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


fn main() raises:
    print("# LineString\n")

    test_constructors()
    test_validate()
    test_memory_layout()
    test_get_item()
    test_equality_ops()
    test_is_empty()
    test_repr()
    test_str()
    test_wkt()

    # TODO: https://github.com/modularml/mojo/issues/1160
    # test_is_simple()
    # TODO: https://github.com/modularml/mojo/issues/1160
    # test_from_json()
    # TODO: https://github.com/modularml/mojo/issues/1160
    # test_from_wkt()

    print()


fn test_constructors() raises:
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


fn test_validate() raises:
    print("is_valid()...")

    var err = String()
    var valid: Bool = False

    valid = LineString2(Point2(lon, lat), Point2(lon, lat)).is_valid(err)
    assert_true(not valid, "is_valid")
    assert_true(
        err == "LineStrings with exactly two identical points are invalid.",
        "unexpected error value",
    )

    valid = LineString2(Point2(lon, lat)).is_valid(err)
    assert_true(
        err == "LineStrings must have either 0 or 2 or more points.",
        "unexpected error value",
    )

    valid = LineString2(Point2(lon, lat), Point2(lon + 1, lat + 1), Point2(lon, lat)).is_valid(err)
    assert_true(
        err == "LineStrings must not be closed: try LinearRing.",
        "unexpected error value",
    )

    print("✅")


fn test_memory_layout() raises:
    # Test if LineString fills the Layout struct correctly.
    print("memory_layout...")

    # equality check each point by indexing into the LineString.
    var points_vec20 = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec20.push_back(Point2(lon + n, lat - n))
    let lstr = LineString2(points_vec20)
    for n in range(0, 10):
        let expect_pt = Point2(lon + n, lat - n)
        assert_true(lstr[n] == expect_pt, "memory_layout")

    # here the geometry_offsets, part_offsets, and ring_offsets are unused because
    # of using "struct coordinate representation" (tensor)
    let layout = lstr.memory_layout
    assert_true(layout.geometry_offsets.num_elements() == 0, "geo_arrow geometry_offsets")
    assert_true(layout.part_offsets.num_elements() == 0, "geo_arrow part_offsets")
    assert_true(layout.ring_offsets.num_elements() == 0, "geo_arrow ring_offsets")

    print("✅")


fn test_get_item() raises:
    print("get_item...")
    var points_vec = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let lstr = LineString2(points_vec)
    for n in range(0, 10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = lstr[n]
        assert_true(got_pt == expect_pt, "get_item")
    print("✅")


fn test_equality_ops() raises:
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

    # not equal
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
    assert_true(lstr12 != lstr13, "__ne__")

    var points_vec = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec.push_back(Point2(lon + n, lat - n))

    let lstr2 = LineString2(points_vec)
    let lstr3 = LineString2(points_vec)
    assert_true(lstr2 == lstr3, "__eq__")

    let lstr4 = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    let lstr5 = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(lstr4 == lstr5, "__eq__")

    let lstr6 = LineString2(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr5 != lstr6, "__eq__")
    print("✅")


fn test_is_empty() raises:
    print("is_empty...")
    let empty_lstr = LineString2()
    _ = empty_lstr.is_empty()
    print("✅")


fn test_repr() raises:
    print("__repr__...")
    let lstr = LineString2(Point2(42, lat), Point2(lon, lat))
    let s = lstr.__repr__()
    assert_true(s == "LineString[float32, 2](2 points)", "__repr__")
    print("✅")


fn test_str() raises:
    print("__str__...")
    let lstr = LineString2(Point2(42, lat), Point2(lon, lat))
    # str() is expected to be the same as wkt()
    assert_true(lstr.__str__() == lstr.wkt(), "__str__")
    print("✅")

fn test_wkt() raises:
    print("wkt...")
    let try_wkt = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(
        try_wkt.wkt()
        == "LINESTRING(-108.68000030517578 38.9739990234375, -108.68000030517578"
        " 38.9739990234375, -108.68000030517578 39.9739990234375)",
        "wkt",
    )
    print("✅")


# fn test_json() raises:
#     print("json...")
#     var points_vec = DynamicVector[Point2](10)
#     for n in range(0, 10):
#         points_vec.push_back(Point2(lon + n, lat - n))
#     let json = LineString2(points_vec).json()
#     assert_true(
#         json
#         == '{"type":"LineString","coordinates":[[-108.68000030517578,38.9739990234375],[-107.68000030517578,37.9739990234375],[-106.68000030517578,36.9739990234375],[-105.68000030517578,35.9739990234375],[-104.68000030517578,34.9739990234375],[-103.68000030517578,33.9739990234375],[-102.68000030517578,32.9739990234375],[-101.68000030517578,31.974000930786133],[-100.68000030517578,30.974000930786133],[-99.680000305175781,29.974000930786133]]}',
#         "json",
#     )
#     print("✅")


fn test_is_simple() raises:
    print("is_simple (⚠️ not implemented)")
    try:
        _ = LineString2(Point2(42, lat), Point2(lon, lat)).is_simple()
        raise Error("unreachable")
    except e:
        pass
        # assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO


# fn test_from_json() raises:
#     print("from_json (⚠️  not implemented)")
#     let json_str = String(
#         '{"type":"LineString","coordinates":[[42.0,38.9739990234375],[42.0,38.9739990234375]]}'
#     )
#     let json = Python.import_module("json")
#     let json_dict = json.loads(json_str)

#     try:
#         _ = LineString2.from_json(json_dict)
#         # raise Error("unreachable")
#     except e:
#         assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO


# fn test_from_wkt() raises:
#     print("from_wkt (⚠️  not implemented)")
#     try:
#         _ = LineString2.from_wkt("")
#         # raise Error("unreachable")
#     except e:
#         assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO
