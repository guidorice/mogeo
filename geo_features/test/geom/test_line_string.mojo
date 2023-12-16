from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index
from pathlib import Path

from geo_features.test.pytest import MojoTest
from geo_features.test.constants import lon, lat, height, measure
from geo_features.geom.point import Point, Point64
from geo_features.geom.line_string import LineString


fn main() raises:
    test_constructors()
    test_validate()
    test_memory_layout()
    test_get_item()
    test_equality_ops()
    test_repr()
    test_stringable()
    test_emptyable()
    test_wktable()
    test_jsonable()
    test_geoarrowable()


fn test_constructors() raises:
    var test = MojoTest("variadic list constructor")

    let lstr = LineString(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    test.assert_true(lstr[0] == Point(lon, lat), "variadic list constructor")
    test.assert_true(lstr[1] == Point(lon, lat), "variadic list constructor")
    test.assert_true(lstr[2] == Point(lon, lat + 1), "variadic list constructor")
    test.assert_true(lstr.__len__() == 3, "variadic list constructor")

    test = MojoTest("vector constructor")

    var points_vec = DynamicVector[Point64](10)
    for n in range(10):
        points_vec.push_back(Point(lon + n, lat - n))
    let lstr2 = LineString[DType.float64](points_vec)
    for n in range(10):
        let expect_pt = Point(lon + n, lat - n)
        test.assert_true(lstr2[n] == expect_pt, "vector constructor")
    test.assert_true(lstr2.__len__() == 10, "vector constructor")


fn test_validate() raises:
    let test = MojoTest("is_valid")

    var err = String()
    var valid: Bool = False

    valid = LineString(Point(lon, lat), Point(lon, lat)).is_valid(err)
    test.assert_true(not valid, "is_valid")
    test.assert_true(
        err == "LineStrings with exactly two identical points are invalid.",
        "unexpected error value",
    )

    valid = LineString(Point(lon, lat)).is_valid(err)
    test.assert_true(
        err == "LineStrings must have either 0 or 2 or more points.",
        "unexpected error value",
    )

    valid = LineString(
        Point(lon, lat), Point(lon + 1, lat + 1), Point(lon, lat)
    ).is_valid(err)
    test.assert_true(
        err == "LineStrings must not be closed: try LinearRing.",
        "unexpected error value",
    )


fn test_memory_layout() raises:
    # Test if LineString fills the Layout struct correctly.
    let test = MojoTest("memory_layout")

    # equality check each point by indexing into the LineString.
    var points_vec20 = DynamicVector[Point64](10)
    for n in range(10):
        points_vec20.push_back(Point(lon + n, lat - n))
    let lstr = LineString(points_vec20)
    for n in range(10):
        let expect_pt = Point(lon + n, lat - n)
        test.assert_true(lstr[n] == expect_pt, "memory_layout")

    # here the geometry_offsets, part_offsets, and ring_offsets are unused because
    # of using "struct coordinate representation" (tensor)
    let layout = lstr.data
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
    let lstr = LineString(points_vec)
    for n in range(10):
        let expect_pt = Point(lon + n, lat - n)
        let got_pt = lstr[n]
        test.assert_true(got_pt == expect_pt, "get_item")


fn test_equality_ops() raises:
    let test = MojoTest("equality operators")

    # partial simd_load (n - i < nelts)
    let lstr8 = LineString(
        Point(1, 2), Point(3, 4), Point(5, 6), Point(7, 8), Point(9, 10)
    )
    let lstr9 = LineString(
        Point(1.1, 2.1),
        Point(3.1, 4.1),
        Point(5.1, 6.1),
        Point(7.1, 8.1),
        Point(9.1, 10.1),
    )
    test.assert_true(lstr8 != lstr9, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    alias PointF32 = Point[DType.float32]
    let lstr10 = LineString(
        PointF32(1, 2),
        PointF32(5, 6),
        PointF32(10, 11),
    )
    let lstr11 = LineString(
        PointF32(1, 2),
        PointF32(5, 6),
        PointF32(10, 11.1),
    )
    test.assert_true(lstr10 != lstr11, "partial simd_load (n - i < nelts) (b)")

    # not equal
    alias PointF16 = Point[DType.float16]
    let lstr12 = LineString(
        PointF16(1, 2),
        PointF16(5, 6),
        PointF16(10, 11),
    )
    let lstr13 = LineString(
        PointF16(1, 2),
        PointF16(5, 6),
        PointF16(10, 11.1),
    )
    test.assert_true(lstr12 != lstr13, "__ne__")

    var points_vec = DynamicVector[Point64](10)
    for n in range(10):
        points_vec.push_back(Point(lon + n, lat - n))

    let lstr2 = LineString(points_vec)
    let lstr3 = LineString(points_vec)
    test.assert_true(lstr2 == lstr3, "__eq__")

    let lstr4 = LineString(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    let lstr5 = LineString(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    test.assert_true(lstr4 == lstr5, "__eq__")

    let lstr6 = LineString(Point(42, lat), Point(lon, lat))
    test.assert_true(lstr5 != lstr6, "__eq__")


fn test_emptyable() raises:
    let test = MojoTest("is_empty")
    let empty_lstr = LineString()
    _ = empty_lstr.is_empty()


fn test_repr() raises:
    let test = MojoTest("__repr__")
    let lstr = LineString(Point(42, lat), Point(lon, lat))
    test.assert_true(
        lstr.__repr__() == "LineString [Point, float64](2 points)", "__repr__"
    )


fn test_sized() raises:
    let test = MojoTest("sized")
    let lstr = LineString(Point(42, lat), Point(lon, lat))
    test.assert_true(len(lstr) == 2, "__len__")


fn test_stringable() raises:
    let test = MojoTest("stringable")
    let lstr = LineString(Point(42, lat), Point(lon, lat))
    test.assert_true(lstr.__str__() == lstr.__repr__(), "__str__")


fn test_wktable() raises:
    test_wkt()
    #    test_from_wkt()


fn test_wkt() raises:
    let test = MojoTest("wkt")
    let lstr = LineString(Point(lon, lat), Point(lon, lat), Point(lon, lat + 1))
    test.assert_true(
        lstr.wkt()
        == "LINESTRING(-108.68000000000001 38.973999999999997, -108.68000000000001"
        " 38.973999999999997, -108.68000000000001 39.973999999999997)",
        "wkt",
    )


fn test_jsonable() raises:
    test_json()
    test_from_json()


fn test_json() raises:
    let test = MojoTest("json")
    var points_vec = DynamicVector[Point64](10)
    for n in range(10):
        points_vec.push_back(Point(lon + n, lat - n))
    let json = LineString(points_vec).json()
    test.assert_true(
        json
        == '{"type":"LineString","coordinates":[[-108.68000000000001,38.973999999999997],[-107.68000000000001,37.973999999999997],[-106.68000000000001,36.973999999999997],[-105.68000000000001,35.973999999999997],[-104.68000000000001,34.973999999999997],[-103.68000000000001,33.973999999999997],[-102.68000000000001,32.973999999999997],[-101.68000000000001,31.973999999999997],[-100.68000000000001,30.973999999999997],[-99.680000000000007,29.973999999999997]]}',
        "json",
    )


fn test_from_json() raises:
    let test = MojoTest("from_json()")

    let json = Python.import_module("orjson")
    let builtins = Python.import_module("builtins")
    let path = Path("geo_features/test/fixtures/geojson/line_string")
    let fixtures = VariadicList("curved.geojson", "straight.geojson", "zigzag.geojson")

    for i in range(len(fixtures)):
        let file = path / fixtures[i]
        with open(file.path, "r") as f:
            let geojson = f.read()
            let geojson_dict = json.loads(geojson)
            _ = LineString.from_json(geojson_dict)


fn test_geoarrowable() raises:
    # TODO: geoarrowable trait
    pass
