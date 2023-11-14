from python import Python
from python.object import PythonObject
from pathlib import Path
from math import nan

from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.test.helpers import assert_true, load_geoarrow_test_fixture
from geo_features.test.constants import lon, lat, height, measure


fn main() raises:
    test_constructors()
    test_repr()
    test_equality_ops()
    test_zero()
    test_is_empty()
    test_getters()
    test_wkt()
    test_json()
    test_from_json()
    test_from_wkt()
    test_from_geoarrow()

    print()


fn test_constructors():
    print("# constructors, aliases")

    # aliases
    _ = Point2(lon, lat)
    _ = Point2(SIMD[DType.float64, 2](lon, lat))
    _ = Point4(lon, lat, height, measure)

    # constructors, parameters
    _ = Point[2, DType.int32](lon, lat)
    _ = Point[2, DType.float64](lon, lat)
    _ = Point[2, DType.float64](lon, lat)
    _ = Point4(SIMD[DType.float64, 4](lon, lat, height, measure))

    # power of two dims: compile time constraint (uncomment to test)
    # _ = Point[3, DType.float32](lon, lat)

fn test_repr() raises:
    print("# repr")
    let pt1 = Point(lon, lat)
    assert_true(
        pt1.__repr__() == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
        "__repr__",
    )
    let pt2 = Point(SIMD[DType.float64, 2](lon, lat))
    assert_true(
        pt2.__repr__() == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
        "__repr__",
    )


fn test_equality_ops() raises:
    print("# equality operators")

    let p2a = Point(lon, lat)
    let p2b = Point(lon, lat)
    assert_true(p2a == p2b, "__eq__")

    let p2i = Point[2, DType.int16](lon, lat)
    let p2ib = Point[2, DType.int16](lon, lat)
    assert_true(p2i == p2ib, "__eq__")

    let p2ic = Point[2, DType.int16](lon + 1, lat)
    assert_true(p2i != p2ic, "__ne_")

    let p4 = Point4(lon, lat, height, measure)
    let p4a = Point4(lon, lat, height, measure)
    let p4b = Point4(lon + 0.001, lat, height, measure)
    assert_true(p4 == p4a, "__eq__")
    assert_true(p4 != p4b, "__eq__")


fn test_is_empty() raises:
    print("# is_empty")
    let pt2 = Point2()
    assert_true(pt2.is_empty(), "is_empty")

    let pt4 = Point4()
    assert_true(pt4.is_empty(), "is_empty")

    let pti = Point[2, DType.int8]()
    assert_true(pti.is_empty(), "is_empty")


fn test_getters() raises:
    print("# getters")

    let pt2 = Point2(lon, lat)
    assert_true(pt2.x() == lon, "p2.x() == lon")
    assert_true(pt2.y() == lat, "p2.y() == lat")

    # Z is compile-time constrained (uncomment to check)
    # _ = pt2.z()
    assert_true(pt2.has_height() == False, "pt.has_height()")

    # M is compile-time constrained (uncomment to check)
    # _ = pt2.m()
    assert_true(pt2.has_measure() == False, "pt.has_height()")

    let p4 = Point4(lon, lat, height, measure)
    assert_true(p4.x() == lon, "p4.x() == lon")
    assert_true(p4.y() == lat, "p4.y() == lat")
    assert_true(p4.z() == height, "p4.z() == height")
    assert_true(p4.m() == measure, "p4.m() == measure")


fn test_json() raises:
    print("# json")

    let pt2 = Point2(lon, lat)
    assert_true(
        pt2.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997]}',
        "json()",
    )
    let pt3 = Point3(lon, lat, height)
    assert_true(
        pt3.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997,8.0]}',
        "json()",
    )

    let pt4 = Point4(lon, lat, height, measure)
    assert_true(
        pt4.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997,8.0]}',
        "json()",
    )


fn test_wkt() raises:
    print("# wkt")

    let pt4 = Point4(lon, lat, height, measure)
    assert_true(
        pt4.wkt() == "POINT(-108.68000000000001 38.973999999999997 8.0 42.0)", "wkt()"
    )

    let p2i = Point[2, DType.int32](lon, lat)
    assert_true(p2i.wkt() == "POINT(-108 38)", "wkt()")


fn test_zero() raises:
    print("# zero")
    let pt2 = Point2.zero()
    assert_true(pt2.x() == 0, "zero().x()")
    assert_true(pt2.y() == 0, "zero().y()")

    let pt4 = Point4.zero()
    assert_true(pt4.x() == 0, "zero().x()")
    assert_true(pt4.y() == 0, "zero().y()")
    assert_true(pt4.z() == 0, "zero().z()")
    assert_true(pt4.m() == 0, "zero().m()")

    let pti = Point[2, DType.int8].zero()
    assert_true(pti.x() == 0, "zero().x()")
    assert_true(pti.y() == 0, "zero().y()")


fn test_from_json() raises:
    print("# from_json")
    let json_str = String('{"type": "Point","coordinates": [102.0, 3.5]}')
    let json = Python.import_module("orjson")
    let json_dict = json.loads(json_str)

    let pt1 = Point[2, DType.float64].from_json(json_dict)
    assert_true(pt1.__repr__() == "Point[2, float64](102.0, 3.5)", "from_json()")

    let pt2 = Point2.from_json(json_dict)
    assert_true(pt2.__repr__() == "Point[2, float64](102.0, 3.5)", "from_json()")

    let pt3 = Point[2, DType.uint8].from_json(json_dict)
    assert_true(pt3.__repr__() == "Point[2, uint8](102, 3)", "from_json()")

    let pt4 = Point[2, DType.float64].from_json(json_str)
    assert_true(pt4.__repr__() == "Point[2, float64](102.0, 3.5)", "from_json()")

    let pt5 = Point2.from_json(json_dict)
    assert_true(pt5.__repr__() == "Point[2, float64](102.0, 3.5)", "from_json()")

    let pt6 = Point[2, DType.uint8].from_json(json_dict)
    assert_true(pt6.__repr__() == "Point[2, uint8](102, 3)", "from_json()")




fn test_from_wkt() raises:
    print("# from_wkt")

    let path = Path("geo_features/test/fixtures/wkt/point/point.wkt")
    var wkt: String
    with open(path, "rb") as f:
        wkt = f.read()

    try:
        let point_2d = Point2.from_wkt(wkt)
        assert_true(
            point_2d.__repr__()
            == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
            "from_wkt()",
        )

        let point_3d = Point3.from_wkt(wkt)
        assert_true(
            point_3d.__repr__()
            == "Point[4, float64](-108.68000000000001, 38.973999999999997, nan, nan)",
            "from_wkt()",
        )

        let point_2d_u8 = Point[2, DType.uint8].from_wkt(wkt)
        assert_true(point_2d_u8.__repr__() == "Point[2, uint8](148, 38)", "from_wkt())")

        let point_2d_f64 = Point[2, DType.float64].from_wkt(wkt)
        assert_true(
            point_2d_f64.__repr__()
            == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
            "from_wkt()",
        )
    except:
        raise Error(
            "from_wkt(): Maybe failed to import_module of shapely? check venv's install"
            " packages."
        )

fn test_from_geoarrow() raises:
    print("# from_geoarrow")

    let ga = Python.import_module("geoarrow.pyarrow")
    let path = Path("geo_features/test/fixtures/geoarrow/geoarrow-data/example")

    var file = path / "example-point.arrow"
    var table = load_geoarrow_test_fixture(file)
    var geoarrow = ga.as_geoarrow(table["geometry"])
    var chunk = geoarrow[0]
    let point_2d = Point2.from_geoarrow(table)
    let expect_coords_2d = SIMD[Point2.dtype, Point2.dims](30.0, 10.0)
    assert_true(point_2d.coords == expect_coords_2d, "expect_coords_2d")

    file = path / "example-point_z.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_3d = Point3.from_geoarrow(table)
    let expect_coords_3d = SIMD[Point3.dtype, Point3.dims](30.0, 10.0, 40.0, nan[Point3.dtype]())
    for i in range(3):
        # cannto check the nan for equality
        assert_true(point_3d.coords[i] == expect_coords_3d[i], "expect_coords_3d")

    file = path / "example-point_zm.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_4d = Point4.from_geoarrow(table)
    let expect_coords_4d = SIMD[Point4.dtype, Point4.dims](30.0, 10.0, 40.0, 300.0)
    assert_true(point_4d.coords == expect_coords_4d, "expect_coords_4d")

    file = path / "example-point_m.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_m = Point3.from_geoarrow(table)
    let expect_coords_m = SIMD[Point3.dtype, Point3.dims](30.0, 10.0, nan[Point3.dtype](), 40.0)
    for i in range(3):
        # cannot check the nan for equality
        assert_true(point_m.coords[i] == expect_coords_m[i], "expect_coords_m")
