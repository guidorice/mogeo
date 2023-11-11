from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from pathlib import Path
from random import rand

from geo_features.test.helpers import assert_true
from geo_features.test.constants import lon, lat, height, measure
from geo_features.geom import (
    Layout2,
    Point,
    Point2,
    Point3,
    Point4,
    LineString,
    LineString2,
    Envelope,
)


fn main() raises:
    test_envelope()


fn test_envelope() raises:
    test_constructors()
    test_with_geos()
    test_repr()
    test_southwesterly_point()
    test_northeasterly_point()
    test_parallelization()

    # test_equality_ops()
    # test_getters()
    # test_wkt()
    # test_json()
    # test_static_methods()
    # test_from_json()
    # test_from_wkt()

    print()


fn test_constructors() raises:
    print("# constructors, aliases")

    # from Point
    _ = Envelope(Point2(lon, lat))
    _ = Envelope(Point3(lon, lat, height))
    _ = Envelope(Point4(lon, lat, height, measure))

    _ = Envelope(Point[2, DType.int8](lon, lat))
    _ = Envelope(Point[4, DType.float64](lon, lat, height, measure))

    # from LineString
    alias Point2_f16 = Point[2, DType.float16]
    _ = Envelope(
        LineString(
            Point2_f16(lon, lat),
            Point2_f16(lon + 1, lat + 1),
            Point2_f16(lon + 2, lat + 2),
            Point2_f16(lon + 3, lat + 3),
            Point2_f16(lon + 4, lat + 4),
            Point2_f16(lon + 5, lat + 5),
        )
    )


fn test_repr() raises:
    print("# repr")

    var e = Envelope(Point2(lon, lat))
    assert_true(
        e.__repr__()
        == "Envelope[float64, 2](-108.68000000000001, 38.973999999999997,"
        " -108.68000000000001, 38.973999999999997)",
        "__repr__",
    )

    e = Envelope(
        LineString(Point2(lon, lat), Point2(lon + 1, lat + 1), Point2(lon + 2, lat + 2))
    )
    assert_true(
        e.__repr__()
        == "Envelope[float64, 2](-108.68000000000001, 38.973999999999997,"
        " -106.68000000000001, 40.973999999999997)",
        "__repr__",
    )


fn test_southwesterly_point() raises:
    print("# southwesterly_point")

    let e = Envelope(Point2(lon, lat))
    let sw_pt = e.southwesterly_point()
    assert_true(sw_pt.x() == lon, "southwesterly_point")
    assert_true(sw_pt.y() == lat, "southwesterly_point")


fn test_northeasterly_point() raises:
    print("# northeasterly_point")
    let x = 42
    print(x)
    let e = Envelope(Point2(lon, lat))
    let sw_pt = e.northeasterly_point()
    assert_true(sw_pt.x() == lon, "northeasterly_point")
    assert_true(sw_pt.y() == lat, "northeasterly_point")


fn test_with_geos() raises:
    """
    Check envelope of complex features using shapely's envelope function.
    """

    print("# shapely/geos")

    let json = Python.import_module("json")
    let builtins = Python.import_module("builtins")
    let shapely = Python.import_module("shapely")
    let envelope = shapely.envelope
    let shape = shapely.geometry.shape
    let mapping = shapely.geometry.mapping

    # LineString

    let path = Path("geo_features/test/fixtures/line_string")
    let fixtures = VariadicList("curved.geojson", "straight.geojson", "zigzag.geojson")
    for i in range(len(fixtures)):
        let file = path / fixtures[i]
        with open(file.path, "r") as f:
            let geojson = f.read()
            let geojson_dict = json.loads(geojson)
            let geometry = shape(geojson_dict)
            let expect_bounds = geometry.bounds
            let lstr = LineString2.from_json(geojson_dict)
            let env = Envelope(lstr)
            for i in range(4):
                assert_true(
                    env.coords[i].cast[DType.float64]()
                    == expect_bounds[i].to_float64(),
                    "envelope index:" + String(i),
                )


fn test_parallelization() raises:
    """
    Verify envelope calcs are the same with and without parallelization.
    """
    print("# parallelize envelope calcs")
    let num_coords = 1000
    var layout = Layout2(num_coords)
    layout.coordinates = rand[DType.float64](2, num_coords)

    let e_parallelized4 = Envelope(layout, num_workers=4)
    let e_parallelized2 = Envelope(layout, num_workers=2)
    let e_serial = Envelope(layout, num_workers=0)
    let e_default = Envelope(layout)

    # print(e_parallelized.coords)
    # print(e_serial.coords)
    # print(e_default.coords)

    assert_true(
        e_parallelized4.coords == e_parallelized2.coords,
        "e_parallelized4 envelope calcs failed.",
    )
    assert_true(
        e_parallelized2.coords == e_serial.coords,
        "e_parallelized2 envelope calcs failed.",
    )
    assert_true(e_serial.coords == e_default.coords, "e_serial envelope calcs failed.")
