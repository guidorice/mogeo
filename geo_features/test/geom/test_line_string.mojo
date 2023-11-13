from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index
from pathlib import Path
from geo_features.test.constants import lon, lat, height, measure

from geo_features.geom.point import (
    Point,
    Point2,
    Point3,
    Point4,
)

from geo_features.geom.line_string import (
    LineString,
    LineString2,
)

from geo_features.test.helpers import assert_true


fn main() raises:
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

    test_from_json()

    # TODO: https://github.com/modularml/mojo/issues/1160
    # test_from_wkt()

    print()


fn test_constructors() raises:
    print("# variadic list constructor")

    let lstr = LineString(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(lstr[0] == Point2(lon, lat), "variadic list constructor")
    assert_true(lstr[1] == Point2(lon, lat), "variadic list constructor")
    assert_true(lstr[2] == Point2(lon, lat + 1), "variadic list constructor")
    assert_true(lstr.__len__() == 3, "variadic list constructor")

    print("# vector constructor")

    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let lstr2 = LineString(points_vec)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        assert_true(lstr2[n] == expect_pt, "vector constructor")
    assert_true(lstr2.__len__() == 10, "vector constructor")


fn test_validate() raises:
    print("# is_valid")

    var err = String()
    var valid: Bool = False

    valid = LineString(Point2(lon, lat), Point2(lon, lat)).is_valid(err)
    assert_true(not valid, "is_valid")
    assert_true(
        err == "LineStrings with exactly two identical points are invalid.",
        "unexpected error value",
    )

    valid = LineString(Point2(lon, lat)).is_valid(err)
    assert_true(
        err == "LineStrings must have either 0 or 2 or more points.",
        "unexpected error value",
    )

    valid = LineString(
        Point2(lon, lat), Point2(lon + 1, lat + 1), Point2(lon, lat)
    ).is_valid(err)
    assert_true(
        err == "LineStrings must not be closed: try LinearRing.",
        "unexpected error value",
    )


fn test_memory_layout() raises:
    # Test if LineString fills the Layout struct correctly.
    print("# memory_layout")

    # equality check each point by indexing into the LineString.
    var points_vec20 = DynamicVector[Point2](10)
    for n in range(10):
        points_vec20.push_back(Point2(lon + n, lat - n))
    let lstr = LineString(points_vec20)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        assert_true(lstr[n] == expect_pt, "memory_layout")

    # here the geometry_offsets, part_offsets, and ring_offsets are unused because
    # of using "struct coordinate representation" (tensor)
    let layout = lstr.memory_layout
    assert_true(
        layout.geometry_offsets.num_elements() == 0, "geo_arrow geometry_offsets"
    )
    assert_true(layout.part_offsets.num_elements() == 0, "geo_arrow part_offsets")
    assert_true(layout.ring_offsets.num_elements() == 0, "geo_arrow ring_offsets")


fn test_get_item() raises:
    print("# get_item")
    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let lstr = LineString(points_vec)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = lstr[n]
        assert_true(got_pt == expect_pt, "get_item")


fn test_equality_ops() raises:
    print("# equality operators")

    # partial simd_load (n - i < nelts)
    let lstr8 = LineString(
        Point2(1, 2), Point2(3, 4), Point2(5, 6), Point2(7, 8), Point2(9, 10)
    )
    let lstr9 = LineString(
        Point2(1.1, 2.1),
        Point2(3.1, 4.1),
        Point2(5.1, 6.1),
        Point2(7.1, 8.1),
        Point2(9.1, 10.1),
    )
    assert_true(lstr8 != lstr9, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    alias Point2F32 = Point[2, DType.float32]
    let lstr10 = LineString(
        Point2F32(1, 2),
        Point2F32(5, 6),
        Point2F32(10, 11),
    )
    let lstr11 = LineString(
        Point2F32(1, 2),
        Point2F32(5, 6),
        Point2F32(10, 11.1),
    )
    assert_true(lstr10 != lstr11, "partial simd_load (n - i < nelts) (b)")

    # not equal
    alias Point2F16 = Point[2, DType.float16]
    let lstr12 = LineString(
        Point2F16(1, 2),
        Point2F16(5, 6),
        Point2F16(10, 11),
    )
    let lstr13 = LineString(
        Point2F16(1, 2),
        Point2F16(5, 6),
        Point2F16(10, 11.1),
    )
    assert_true(lstr12 != lstr13, "__ne__")

    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))

    let lstr2 = LineString(points_vec)
    let lstr3 = LineString(points_vec)
    assert_true(lstr2 == lstr3, "__eq__")

    let lstr4 = LineString(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    let lstr5 = LineString(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(lstr4 == lstr5, "__eq__")

    let lstr6 = LineString(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr5 != lstr6, "__eq__")


fn test_is_empty() raises:
    print("# is_empty")
    let empty_lstr = LineString2()
    _ = empty_lstr.is_empty()


fn test_repr() raises:
    print("# __repr__")
    let lstr = LineString(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr.__repr__() == "LineString[2, float64](2 points)", "__repr__")


fn test_str() raises:
    print("# __str__")
    let lstr = LineString(Point2(42, lat), Point2(lon, lat))
    # str() is expected to be the same as wkt()
    assert_true(lstr.__str__() == lstr.wkt(), "__str__")


fn test_wkt() raises:
    print("# wkt")
    let lstr = LineString(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(
        lstr.wkt()
        == "LINESTRING(-108.68000000000001 38.973999999999997, -108.68000000000001"
        " 38.973999999999997, -108.68000000000001 39.973999999999997)",
        "wkt",
    )


# fn test_json() raises:
#     print("json")
#     var points_vec = DynamicVector[Point2](10)
#     for n in range(10):
#         points_vec.push_back(Point2(lon + n, lat - n))
#     let json = LineString2(points_vec).json()
#     assert_true(
#         json
#         == '{"type":"LineString","coordinates":[[-108.68000030517578,38.9739990234375],[-107.68000030517578,37.9739990234375],[-106.68000030517578,36.9739990234375],[-105.68000030517578,35.9739990234375],[-104.68000030517578,34.9739990234375],[-103.68000030517578,33.9739990234375],[-102.68000030517578,32.9739990234375],[-101.68000030517578,31.974000930786133],[-100.68000030517578,30.974000930786133],[-99.680000305175781,29.974000930786133]]}',
#         "json",
#     )


fn test_is_simple() raises:
    print("# is_simple (⚠️ not implemented)")
    try:
        _ = LineString(Point2(42, lat), Point2(lon, lat)).is_simple()
        raise Error("unreachable")
    except e:
        pass
        # assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO


fn test_from_json() raises:
    print("# from_json()")

    let json = Python.import_module("orjson")
    let builtins = Python.import_module("builtins")
    let path = Path("geo_features/test/fixtures/line_string")
    let fixtures = VariadicList("curved.geojson", "straight.geojson", "zigzag.geojson")

    for i in range(len(fixtures)):
        let file = path / fixtures[i]
        with open(file.path, "r") as f:
            let geojson = f.read()
            let geojson_dict = json.loads(geojson)
            _ = LineString2.from_json(geojson_dict)


# fn test_from_wkt() raises:
#     print("from_wkt (⚠️  not implemented)")
#     try:
#         _ = LineString2.from_wkt("")
#         # raise Error("unreachable")
#     except e:
#         assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO
