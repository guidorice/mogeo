from python import Python
from python.object import PythonObject

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

    # test_equality_ops()
    # test_getters()
    # test_wkt()
    # test_json()
    # test_static_methods()
    # test_from_json()
    # test_from_wkt()

    print()


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
