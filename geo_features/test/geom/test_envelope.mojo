from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector

from geo_features.geom import (
    Point,
    Point2,
    Point3,
    Point4,
    LineString,
    LineString2,
    LineString3,
    LineString4,
    Envelope,
    Envelope2,
    Envelope3,
    Envelope4,
)

from geo_features.test.helpers import assert_true
from geo_features.test.constants import lon, lat, height, measure


fn main() raises:
    test_envelope()


fn test_envelope() raises:
    print("# Envelope\n")

    test_constructors()
    test_repr()
    test_southwesterly_point()
    test_northeasterly_point()

    test_with_geos()

    # test_equality_ops()
    # test_getters()
    # test_wkt()
    # test_json()
    # test_static_methods()
    # test_from_json()
    # test_from_wkt()

    print()


from pathlib import Path


fn test_with_geos() raises:
    print("shapely/geos...")
    # check envelope of complex features using shapely's envelope function

    let json = Python.import_module("json")
    let builtins = Python.import_module("builtins")
    let shapely = Python.import_module("shapely")
    let envelope = shapely.envelope
    let shape = shapely.geometry.shape
    let mapping = shapely.geometry.mapping

    # LineString
    var fixtures = Python.evaluate(
        '["curved.geojson", "straight.geojson", "zigzag.geojson"]'
    )
    for file in fixtures:
        with open(
            "geo_features/test/fixtures/line_string/" + file.to_string(), "r"
        ) as f:
            let geojson = f.read()
            let geojson_dict = json.loads(geojson)
            # print(geojson_dict.to_string())
            let geometry = shape(geojson_dict)
            let expect_bounds = geometry.bounds
            print("expect_bounds")
            print(expect_bounds)
            let lstr = LineString2.from_json(geojson_dict)
            let env = Envelope2(lstr)
            print("env.coords:")
            print(env.coords)
            for i in range(0, 4):
                print(i, env.coords[i])
                # print(i, env.coords[i].cast[DType.float64](), expect_bounds[i].to_float64())
                assert_true(env.coords[i].cast[DType.float64]() == expect_bounds[i].to_float64(), "envelope index:" + String(i))

    print("✅")


fn test_constructors() raises:
    print("constructors, aliases:")

    # from Point
    _ = Envelope2(Point2(lon, lat))
    _ = Envelope3(Point3(lon, lat, height))
    _ = Envelope4(Point4(lon, lat, height, measure))

    _ = Envelope[2, DType.int8](Point[2, DType.int8](lon, lat))
    _ = Envelope[4, DType.float64](Point[4, DType.float64](lon, lat, height, measure))

    # from LineString
    _ = Envelope[2, DType.float16](
        LineString[2, DType.float16](
            Point[2, DType.float16](lon, lat),
            Point[2, DType.float16](lon + 1, lat + 1),
            Point[2, DType.float16](lon + 2, lat + 2),
            Point[2, DType.float16](lon + 3, lat + 3),
            Point[2, DType.float16](lon + 4, lat + 4),
            Point[2, DType.float16](lon + 5, lat + 5),
        )
    )
    print("✅")


fn test_repr() raises:
    print("repr...")

    let e = Envelope2(Point2(lon, lat))
    assert_true(
        e.__repr__()
        == "Envelope[float64, 2](-108.68000000000001, 38.973999999999997,"
        " -108.68000000000001, 38.973999999999997)",
        "__repr__",
    )

    let e2 = Envelope2(
        LineString2(
            Point2(lon, lat), Point2(lon + 1, lat + 1), Point2(lon + 2, lat + 2)
        )
    )
    assert_true(
        e2.__repr__()
        == "Envelope[float64, 2](-108.68000000000001, -108.68000000000001,"
        " -107.68000000000001, -106.68000000000001)",
        "__repr__",
    )
    print("✅")


fn test_southwesterly_point() raises:
    print("southwesterly_point...")

    let e = Envelope2(Point2(lon, lat))
    let sw_pt = e.southwesterly_point()
    assert_true(sw_pt.x() == lon, "southwesterly_point")
    assert_true(sw_pt.y() == lat, "southwesterly_point")

    print("✅")


fn test_northeasterly_point() raises:
    print("northeasterly_point...")

    let e = Envelope2(Point2(lon, lat))
    let sw_pt = e.northeasterly_point()
    assert_true(sw_pt.x() == lon, "northeasterly_point")
    assert_true(sw_pt.y() == lat, "northeasterly_point")

    print("✅")
