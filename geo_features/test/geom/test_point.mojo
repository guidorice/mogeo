from python import Python
from python.object import PythonObject
from pathlib import Path

from geo_features.geom.empty import empty_value, is_empty
from geo_features.geom.point import Point, CoordDims
from geo_features.test.helpers import load_geoarrow_test_fixture
from geo_features.test.pytest import MojoTest
from geo_features.test.constants import lon, lat, height, measure


fn main() raises:
    test_constructors()
    test_repr()
    test_has_height()
    test_has_measure()
    test_equality_ops()
    test_zero()
    test_is_empty()
    test_getters()
    test_setters()
    test_wkt()
    test_json()
    test_from_json()
    test_from_wkt()
    test_from_geoarrow()


fn test_constructors():
    let test = MojoTest("constructors")

    _ = Point()
    _ = Point(lon, lat)
    _ = Point(lon, lat, height)
    _ = Point(lon, lat, measure)
    _ = Point(lon, lat, height, measure)
    _ = Point[DType.int32]()
    _ = Point[DType.float32]()
    _ = Point[DType.int32](lon, lat)
    _ = Point[DType.float32](lon, lat)
    _ = Point[dtype=DType.float16](
        SIMD[DType.float16, 4](lon, lat, height, measure)
    )
    _ = Point[dtype=DType.float32](
        SIMD[DType.float32, 4](lon, lat, height, measure)
    )


fn test_repr() raises:
    let test = MojoTest("repr")

    let pt = Point(lon, lat)
    test.assert_true(pt.__repr__() == "Point [float64](-108.68000000000001, 38.973999999999997, nan, nan)", "repr")

    let pt_z = Point(lon, lat, height)
    test.assert_true(pt_z.__repr__() == "Point Z [float64](-108.68000000000001, 38.973999999999997, 8.0, 8.0)", "repr")

    # the variadic list constructor cannot distinguish Point Z from Point M, so use the set_ogc_dims method.
    var pt_m = pt_z
    pt_m.set_ogc_dims(CoordDims.PointM)
    test.assert_true(pt_m.__repr__() == "Point M [float64](-108.68000000000001, 38.973999999999997, 8.0, 8.0)", "repr")

    let pt_zm = Point(lon, lat, height, measure)
    test.assert_true(pt_zm.__repr__() == "Point ZM [float64](-108.68000000000001, 38.973999999999997, 8.0, 42.0)", "repr")


fn test_has_height() raises:
    let test = MojoTest("has_height")
    let pt_z = Point(lon, lat, height)
    test.assert_true(pt_z.has_height(), "has_height")


fn test_has_measure() raises:
    let test = MojoTest("has_measure")
    let pt_m = Point(lon, lat, measure)
    test.assert_true(pt_m.has_measure(), "has_measure")


fn test_empty_default_values() raises:
    let test = MojoTest("test empty default values")

    let pt_4 = Point(lon, lat)
    let expect_value = empty_value[pt_4.dtype]()
    test.assert_true(pt_4.coords[2] == expect_value, "NaN expected")
    test.assert_true(pt_4.coords[3] == expect_value, "NaN expected")

    let pt_4_int = Point[DType.uint16](lon, lat)
    let expect_value_int = empty_value[pt_4_int.dtype]()
    test.assert_true(pt_4_int.coords[2] == expect_value_int, "max_finite expected")
    test.assert_true(pt_4_int.coords[3] == expect_value_int, "max_finite expected")


fn test_equality_ops() raises:
    let test = MojoTest("equality operators")

    let p2a = Point(lon, lat)
    let p2b = Point(lon, lat)
    test.assert_true(p2a == p2b, "__eq__")

    let p2i = Point[DType.int16](lon, lat)
    let p2ib = Point[DType.int16](lon, lat)
    test.assert_true(p2i == p2ib, "__eq__")

    let p2ic = Point[DType.int16](lon + 1, lat)
    test.assert_true(p2i != p2ic, "__ne_")

    let p4 = Point(lon, lat, height, measure)
    let p4a = Point(lon, lat, height, measure)
    let p4b = Point(lon + 0.001, lat, height, measure)
    test.assert_true(p4 == p4a, "__eq__")
    test.assert_true(p4 != p4b, "__eq__")


fn test_zero() raises:
    let test = MojoTest("zero")

    let pt = Point.zero()
    test.assert_true(pt.x() == 0, "zero().x()")
    test.assert_true(pt.y() == 0, "zero().y()")


fn test_is_empty() raises:
    let test = MojoTest("is_empty")

    let pt2 = Point()
    test.assert_true(pt2.is_empty(), "is_empty")

    let pti = Point[DType.int8]()
    test.assert_true(pti.is_empty(), "is_empty")

    let pt_z = Point[DType.int8](CoordDims.PointZ)
    test.assert_true(pt_z.is_empty(), "is_empty")

    let pt_m = Point[DType.int8](CoordDims.PointM)
    test.assert_true(pt_m.is_empty(), "is_empty")

    let pt_zm = Point[DType.int8](CoordDims.PointZM)
    test.assert_true(pt_zm.is_empty(), "is_empty")


fn test_getters() raises:
    let test = MojoTest("getters")

    let pt2 = Point(lon, lat)
    test.assert_true(pt2.x() == lon, "p2.x() == lon")
    test.assert_true(pt2.y() == lat, "p2.y() == lat")

    let pt_z = Point(lon, lat, height)
    test.assert_true(pt_z.x() == lon, "pt_z.x() == lon")
    test.assert_true(pt_z.y() == lat, "pt_z.y() == lat")
    test.assert_true(pt_z.z() == height, "pt_z.z() == height")

    let pt_m = Point(lon, lat, measure)
    test.assert_true(pt_m.x() == lon, "pt_m.x() == lon")
    test.assert_true(pt_m.y() == lat, "pt_m.y() == lat")
    test.assert_true(pt_m.m() == measure, "pt_m.m() == measure")

    let point_zm = Point(lon, lat, height, measure)
    test.assert_true(point_zm.x() == lon, "point_zm.x() == lon")
    test.assert_true(point_zm.y() == lat, "point_zm.y() == lat")
    test.assert_true(point_zm.z() == height, "point_zm.z() == height")
    test.assert_true(point_zm.m() == measure, "point_zm.m() == measure")


fn test_setters() raises:
    let test = MojoTest("setters")

    var pt = Point(lon, lat, measure)
    pt.set_ogc_dims(CoordDims.PointM)
    test.assert_true(pt.ogc_dims == CoordDims.PointM, "set_ogc_dims")


fn test_json() raises:
    let test = MojoTest("json")

    let pt2 = Point(lon, lat)
    test.assert_true(
        pt2.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997]}',
        "json()",
    )
    let pt3 = Point(lon, lat, height)
    test.assert_true(
        pt3.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997,8.0]}',
        "json()",
    )

    let pt4 = Point(lon, lat, height, measure)
    test.assert_true(
        pt4.json()
        == '{"type":"Point","coordinates":[-108.68000000000001,38.973999999999997,8.0]}',
        "json()",
    )



fn test_from_json() raises:
    let test = MojoTest("from_json")

    let orjson = Python.import_module("orjson")
    let json_str = String('{"type":"Point","coordinates":[102.001, 3.502]}')
    let json_dict = orjson.loads(json_str)

    let pt2 = Point.from_json(json_dict)
    test.assert_true(pt2.x() == 102.001, "pt2.x()")
    test.assert_true(pt2.y() == 3.502, "pt2.y()")

    let ptz = Point.from_json(json_dict)
    test.assert_true(ptz.x() == 102.001, "ptz.x()")
    test.assert_true(ptz.y() == 3.502, "ptz.y()")

    let pt_f32 = Point[dtype=DType.float32].from_json(json_str)
    test.assert_true(pt_f32.x() == 102.001, "pt_f32.x()")
    test.assert_true(pt_f32.y() == 3.502, "pt_f32.y()")

    let pt_int = Point[dtype=DType.uint8].from_json(json_dict)
    test.assert_true(pt_int.x() == 102, "pt_int.x()")
    test.assert_true(pt_int.y() == 3, "pt_int.y()")


fn test_wkt() raises:
    let test = MojoTest("wkt")

    let pt = Point(lon, lat)
    test.assert_true(
        pt.wkt() == "Point (-108.68000000000001 38.973999999999997)", "wkt"
    )

    let pt_z = Point(lon, lat, height)
    test.assert_true(
        pt_z.wkt() == "Point Z (-108.68000000000001 38.973999999999997 8.0)", "wkt"
    )

    var pt_m = Point(lon, lat, measure)
    pt_m.set_ogc_dims(CoordDims.PointM)
    test.assert_true(
        pt_m.wkt() == "Point M (-108.68000000000001 38.973999999999997 42.0)", "wkt"
    )

    let pt_zm = Point(lon, lat, height, measure)
    test.assert_true(
        pt_zm.wkt() == "Point ZM (-108.68000000000001 38.973999999999997 8.0 42.0)", "wkt"
    )

    let p2i = Point[DType.int32](lon, lat)
    test.assert_true(p2i.wkt() == "Point (-108 38)", "wkt")


fn test_from_wkt() raises:
    let test = MojoTest("from_wkt")

    let path = Path("geo_features/test/fixtures/wkt/point/point.wkt")
    let wkt: String
    with open(path, "rb") as f:
        wkt = f.read()

    let expect_x = -108.68000000000001
    let expect_y = 38.973999999999997
    try:
        let point_2d = Point.from_wkt(wkt)
        test.assert_true(point_2d.x() == expect_x, "point_2d.x()")
        test.assert_true(point_2d.y() == expect_y, "point_2d.y()")

        let point_3d = Point.from_wkt(wkt)
        test.assert_true(
            point_3d.__repr__()
            == "Point [float64](-108.68000000000001, 38.973999999999997, nan, nan)",
            "from_wkt",
        )

        let point_2d_u8 = Point[DType.uint8].from_wkt(wkt)
        test.assert_true(
            point_2d_u8.__repr__() == "Point [uint8](148, 38, 255, 255)", "from_wkt())"
        )

        let point_2d_f32 = Point[DType.float32].from_wkt(wkt)
        test.assert_true(
            point_2d_f32.__repr__()
            == "Point [float32](-108.68000030517578, 38.9739990234375, nan, nan)",
            "from_wkt",
        )
    except:
        raise Error(
            "from_wkt(): Maybe failed to import_module of shapely? check venv's install"
            " packages."
        )


fn test_from_geoarrow() raises:
    let test = MojoTest("from_geoarrow")

    let ga = Python.import_module("geoarrow.pyarrow")
    let path = Path("geo_features/test/fixtures/geoarrow/geoarrow-data/example")
    let empty = empty_value[DType.float64]()
    var file = path / "example-point.arrow"
    var table = load_geoarrow_test_fixture(file)
    var geoarrow = ga.as_geoarrow(table["geometry"])
    var chunk = geoarrow[0]
    let point_2d = Point.from_geoarrow(table)
    let expect_point_2d = Point(SIMD[point_2d.dtype, point_2d.simd_dims](30.0, 10.0, empty, empty))
    test.assert_true(point_2d == expect_point_2d, "expect_coords_2d")

    file = path / "example-point_z.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_3d = Point.from_geoarrow(table)
    let expect_point_3d = Point(
        SIMD[point_3d.dtype, point_3d.simd_dims](30.0, 10.0, 40.0, empty_value[point_3d.dtype]())
    )
    for i in range(3):
        # cannot check the nan for equality
        test.assert_true(point_3d == expect_point_3d, "expect_point_3d")

    file = path / "example-point_zm.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_4d = Point.from_geoarrow(table)
    let expect_point_4d = Point(
        SIMD[point_4d.dtype, point_4d.simd_dims](30.0, 10.0, 40.0, 300.0)
    )
    test.assert_true(point_4d == expect_point_4d, "expect_point_4d")

    file = path / "example-point_m.arrow"
    table = load_geoarrow_test_fixture(file)
    geoarrow = ga.as_geoarrow(table["geometry"])
    chunk = geoarrow[0]
    # print(chunk.wkt)
    let point_m = Point.from_geoarrow(table)
    let expect_coords_m = SIMD[point_m.dtype, point_m.simd_dims](
        30.0, 10.0, 300.0, empty_value[point_m.dtype]()
    )
    for i in range(3):  # cannot equality check the NaN
        test.assert_true(point_m.coords[i] == expect_coords_m[i], "expect_coords_m")
    test.assert_true(is_empty(point_m.coords[3]), "expect_coords_m")
