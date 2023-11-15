from python import Python
from python.object import PythonObject
from pathlib import Path
from math import nan, isnan

from geo_features.geom.point import Point, Point2, PointZ, PointM, PointZM
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
    _ = Point2()
    _ = Point2(lon, lat) 

    _ = PointZ(lon, lat, height)
    _ = PointZ()

    _ = PointM()
    _ = PointM(lon, lat, measure)

    _ = PointZM()
    _ = PointZM(lon, lat, height, measure)

    # try all constructors, various parameters
    
    _ = Point[2, DType.int32](lon, lat)
    _ = Point[2, DType.float64](lon, lat)

    _ = Point[4, DType.float64](lon, lat)  # TODO assert NaN for dims 2-4

    _ = Point[dtype=DType.float16, dims=4, has_height=True, has_measure=True](SIMD[DType.float16, 4](lon, lat, height, measure))
    _ = Point[dtype=DType.float32, dims=4](SIMD[DType.float32, 4](lon, lat, height, measure))

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

    let p4 = PointZM(lon, lat, height, measure)
    let p4a = PointZM(lon, lat, height, measure)
    let p4b = PointZM(lon + 0.001, lat, height, measure)
    assert_true(p4 == p4a, "__eq__")
    assert_true(p4 != p4b, "__eq__")


fn test_zero() raises:
    print("# zero")
    let pt2 = Point2.zero()
    assert_true(pt2.x() == 0, "zero().x()")
    assert_true(pt2.y() == 0, "zero().y()")

    let pt_z = PointZ.zero()
    assert_true(pt_z.x() == 0, "zero().x()")
    assert_true(pt_z.y() == 0, "zero().y()")
    assert_true(pt_z.z() == 0, "zero().z()")

    let pt_m = PointM.zero()
    assert_true(pt_m.x() == 0, "zero().x()")
    assert_true(pt_m.y() == 0, "zero().y()")
    assert_true(pt_m.m() == 0, "zero().m()")

    let pt_zm = PointZM.zero()
    assert_true(pt_zm.x() == 0, "zero().x()")
    assert_true(pt_zm.y() == 0, "zero().y()")
    assert_true(pt_zm.z() == 0, "zero().z()")
    assert_true(pt_zm.m() == 0, "zero().m()")

    let pti = Point[2, DType.int8].zero()
    assert_true(pti.x() == 0, "zero().x()")
    assert_true(pti.y() == 0, "zero().y()")


fn test_is_empty() raises:
    print("# is_empty")
    let pt2 = Point2()
    assert_true(pt2.is_empty(), "is_empty")

    let pt_z = PointZ()
    assert_true(pt_z.is_empty(), "is_empty")

    let pt_m = PointM()
    assert_true(pt_m.is_empty(), "is_empty")

    let pt_zm = PointZM()
    assert_true(pt_zm.is_empty(), "is_empty")

    let pti = Point[2, DType.int8]()
    assert_true(pti.is_empty(), "is_empty")


fn test_getters() raises:
    print("# getters")

    let pt2 = Point2(lon, lat)
    assert_true(pt2.x() == lon, "p2.x() == lon")
    assert_true(pt2.y() == lat, "p2.y() == lat")
    # Z is compile-time constrained (uncomment to check)
    # _ = pt2.z()
    # M is compile-time constrained (uncomment to check)
    # _ = pt2.m()

    let pt_z = PointZ(lon, lat, height)
    assert_true(pt_z.x() == lon, "pt_z.x() == lon")
    assert_true(pt_z.y() == lat, "pt_z.y() == lat")
    assert_true(pt_z.z() == height, "pt_z.z() == height")
    # M is compile-time constrained (uncomment to check)
    # _ = pt_z.m()

    let pt_m = PointM(lon, lat, measure)
    print(pt_m.coords)
    assert_true(pt_m.x() == lon, "pt_m.x() == lon")
    assert_true(pt_m.y() == lat, "pt_m.y() == lat")
    assert_true(pt_m.m() == measure, "pt_m.m() == measure")
    # Z is compile-time constrained (uncomment to check)
    # _ = pt_m.z()

    let point_zm = PointZM(lon, lat, height, measure)
    assert_true(point_zm.x() == lon, "point_zm.x() == lon")
    assert_true(point_zm.y() == lat, "point_zm.y() == lat")
    assert_true(point_zm.z() == height, "point_zm.z() == height")
    assert_true(point_zm.m() == measure, "point_zm.m() == measure")


fn test_json() raises:
    print("# json")

    let pt2 = Point2(lon, lat)
    assert_true(
        pt2.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997]}',
        "json()",
    )
    let pt3 = PointZ(lon, lat, height)
    assert_true(
        pt3.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997,8.0]}',
        "json()",
    )

    let pt4 = PointZM(lon, lat, height, measure)
    assert_true(
        pt4.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997,8.0]}',
        "json()",
    )


fn test_wkt() raises:
    print("# wkt")

    let pt4 = PointZM(lon, lat, height, measure)
    assert_true(
        pt4.wkt() == "POINT(-108.68000000000001 38.973999999999997 8.0 42.0)", "wkt()"
    )

    let p2i = Point[2, DType.int32](lon, lat)
    assert_true(p2i.wkt() == "POINT(-108 38)", "wkt()")


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

        let point_3d = PointZ.from_wkt(wkt)
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
    let point_3d = PointZ.from_geoarrow(table)
    let expect_coords_3d = SIMD[PointZ.dtype, PointZ.dims](30.0, 10.0, 40.0, nan[PointZ.dtype]())
    for i in range(3):
        # cannto check the nan for equality
        assert_true(point_3d.coords[i] == expect_coords_3d[i], "expect_coords_3d")

    file = path / "example-point_zm.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_4d = PointZM.from_geoarrow(table)
    let expect_coords_4d = SIMD[PointZM.dtype, PointZM.dims](30.0, 10.0, 40.0, 300.0)
    assert_true(point_4d.coords == expect_coords_4d, "expect_coords_4d")

    file = path / "example-point_m.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_m = PointM.from_geoarrow(table)
    let expect_coords_m = SIMD[PointM.dtype, PointM.dims](30.0, 10.0, 300.0, nan[PointM.dtype]())
    for i in range(3):  # cannot equality check the NaN
        assert_true(point_m.coords[i] == expect_coords_m[i], "expect_coords_m")
    assert_true(isnan(point_m.coords[3]), "expect_coords_m")