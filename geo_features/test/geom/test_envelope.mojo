from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from pathlib import Path
from random import rand

from geo_features.test.pytest import MojoTest
from geo_features.test.constants import lon, lat, height, measure
from geo_features.geom import (
    Layout,
    Point,
    Point2,
    PointZ,
    PointM,
    PointZM,
    LineString,
    Envelope,
    Envelope2,
    EnvelopeZ,
    EnvelopeM,
    EnvelopeZM,
)


fn main() raises:
    test_envelope()


fn test_envelope() raises:
    test_constructors()
    test_repr()
    test_min_max()
    test_southwesterly_point()
    test_northeasterly_point()
    test_with_geos()
    test_parallelization()
    test_equality_ops()
    # test_wkt()
    # test_json()
    # test_static_methods()
    # test_from_json()
    # test_from_wkt()


fn test_constructors() raises:
    let test = MojoTest("constructors, aliases")

    # # from Point
    _ = Envelope(Point2(lon, lat))
    _ = EnvelopeZ(PointZ(lon, lat, height))
    _ = EnvelopeM(PointM(lon, lat, measure))
    _ = EnvelopeZM(PointZM(lon, lat, height, measure))

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
    let test = MojoTest("repr")

    # TODO: more variations of envelope structs

    var e = Envelope(Point2(lon, lat))
    test.assert_true(
        e.__repr__()
        == "Envelope[2, float64](-108.68000000000001, 38.973999999999997,"
        " -108.68000000000001, 38.973999999999997)",
        "__repr__",
    )

    e = Envelope(
        LineString(Point2(lon, lat), Point2(lon + 1, lat + 1), Point2(lon + 2, lat + 2))
    )
    test.assert_true(
        e.__repr__()
        == "Envelope[2, float64](-108.68000000000001, 38.973999999999997,"
        " -106.68000000000001, 40.973999999999997)",
        "__repr__",
    )


fn test_min_max() raises:
    let test = MojoTest("min/max methods")

    let e_of_pt2 = Envelope(Point2(lon, lat))
    test.assert_true(e_of_pt2.min_x() == lon, "min_x")
    test.assert_true(e_of_pt2.min_y() == lat, "min_y")

    test.assert_true(e_of_pt2.max_x() == lon, "max_x")
    test.assert_true(e_of_pt2.max_y() == lat, "max_y")

    let e_of_ls2 = Envelope(
        LineString(
            Point2(lon, lat),
            Point2(lon + 1, lat + 1),
            Point2(lon + 2, lat + 5),
            Point2(lon + 5, lat + 3),
            Point2(lon + 4, lat + 4),
            Point2(lon + 3, lat + 2),
        )
    )
    test.assert_true(e_of_ls2.min_x() == lon, "min_x")
    test.assert_true(e_of_ls2.min_y() == lat, "min_y")

    test.assert_true(e_of_ls2.max_x() == lon + 5, "max_x")
    test.assert_true(e_of_ls2.max_y() == lat + 5, "max_y")

    let e_of_ls3 = Envelope(
        LineString(
            PointZ(lon, lat, height),
            PointZ(lon + 1, lat + 1, height - 1),
            PointZ(lon + 2, lat + 2, height - 2),
            PointZ(lon + 7, lat + 5, height - 5),
            PointZ(lon + 4, lat + 4, height - 4),
            PointZ(lon + 5, lat + 3, height - 3),
        )
    )
    test.assert_true(e_of_ls3.min_x() == lon, "min_x")
    test.assert_true(e_of_ls3.min_y() == lat, "min_y")
    test.assert_true(e_of_ls3.min_z() == height - 5, "min_z")

    test.assert_true(e_of_ls3.max_x() == lon + 7, "max_x")
    test.assert_true(e_of_ls3.max_y() == lat + 5, "max_y")
    test.assert_true(e_of_ls3.max_z() == height, "max_z")

    let e_of_ls4 = Envelope(
        LineString(
            PointZ(lon, lat, height, measure),
            PointZ(lon + 1, lat + 1, height - 1, measure + 0.01),
            PointZ(lon + 2, lat + 2, height - 7, measure + 0.05),
            PointZ(lon + 5, lat + 3, height - 3, measure + 0.03),
            PointZ(lon + 4, lat + 5, height - 4, measure + 0.04),
            PointZ(lon + 3, lat + 4, height - 5, measure + 0.02),
        )
    )

    test.assert_true(e_of_ls4.min_x() == lon, "min_x")
    test.assert_true(e_of_ls4.min_y() == lat, "min_y")
    test.assert_true(e_of_ls4.min_z() == height - 7, "min_z")
    test.assert_true(e_of_ls4.min_m() == measure, "min_m")

    test.assert_true(e_of_ls4.max_x() == lon + 5, "max_x")
    test.assert_true(e_of_ls4.max_y() == lat + 5, "max_y")
    test.assert_true(e_of_ls4.max_z() == height, "max_z")
    test.assert_true(e_of_ls4.max_m() == measure + 0.05, "max_m")


fn test_southwesterly_point() raises:
    let test = MojoTest("southwesterly_point")
    let e = Envelope(Point2(lon, lat))
    let sw_pt = e.southwesterly_point()
    test.assert_true(sw_pt.x() == lon, "southwesterly_point")
    test.assert_true(sw_pt.y() == lat, "southwesterly_point")


fn test_northeasterly_point() raises:
    let test = MojoTest("northeasterly_point")
    let e = Envelope(Point2(lon, lat))
    let sw_pt = e.northeasterly_point()
    test.assert_true(sw_pt.x() == lon, "northeasterly_point")
    test.assert_true(sw_pt.y() == lat, "northeasterly_point")


fn test_with_geos() raises:
    """
    Check envelope of complex features using shapely's envelope function.
    """
    let test = MojoTest("shapely/geos")

    let json = Python.import_module("orjson")
    let builtins = Python.import_module("builtins")
    let shapely = Python.import_module("shapely")

    let envelope = shapely.envelope
    let shape = shapely.geometry.shape
    let mapping = shapely.geometry.mapping

    # LineString

    let path = Path("geo_features/test/fixtures/geojson/line_string")
    let fixtures = VariadicList("curved.geojson", "straight.geojson", "zigzag.geojson")
    for i in range(len(fixtures)):
        let file = path / fixtures[i]
        with open(file, "r") as f:
            let geojson = f.read()
            let geojson_dict = json.loads(geojson)
            let geometry = shape(geojson_dict)
            let expect_bounds = geometry.bounds
            let lstr = LineString.from_json(geojson_dict)
            let env = Envelope(lstr)
            for i in range(4):
                test.assert_true(
                    env.coords[i].cast[DType.float64]()
                    == expect_bounds[i].to_float64(),
                    "envelope index:" + String(i),
                )


fn test_parallelization() raises:
    """
    Verify envelope calcs are the same with and without parallelization.
    """
    let test = MojoTest("parallelize envelope calcs")

    let num_coords = 10000
    var layout = Layout(num_coords)
    layout.coordinates = rand[DType.float64](4, num_coords)

    let e_parallelized7 = Envelope(layout, num_workers=7)
    let e_parallelized3 = Envelope(layout, num_workers=3)
    let e_serial = Envelope(layout, num_workers=0)
    let e_default = Envelope(layout)

    test.assert_true(
        e_parallelized7.coords == e_parallelized3.coords,
        "parallelize envelope calcs failed.",
    )
    test.assert_true(
        e_parallelized3.coords == e_serial.coords,
        "parallelize envelope calcs failed.",
    )
    test.assert_true(
        e_serial.coords == e_default.coords, "parallelize envelope calcs failed."
    )


fn test_equality_ops() raises:
    """
    Test __eq__ and __ne__ methods.
    """
    let test = MojoTest("equality ops")

    let e2 = Envelope(Point2(lon, lat))
    let e2_eq = Envelope(Point2(lon, lat))
    let e2_ne = Envelope(Point2(lon + 0.01, lat - 0.02))
    test.assert_true(e2 == e2_eq, "__eq__")
    test.assert_true(e2 != e2_ne, "__ne__")

    let e3 = Envelope(PointZ(lon, lat, height))
    let e3_eq = Envelope(PointZ(lon, lat, height))
    let e3_ne = Envelope(PointZ(lon, lat, height * 2))
    test.assert_true(e3 == e3_eq, "__eq__")
    test.assert_true(e3 != e3_ne, "__ne__")

    let e4 = Envelope(PointZM(lon, lat, height, measure))
    let e4_eq = Envelope(PointZM(lon, lat, height, measure))
    let e4_ne = Envelope(PointZM(lon, lat, height, measure * 2))
    test.assert_true(e4 == e4_eq, "__eq__")
    test.assert_true(e4 != e4_ne, "__ne__")
