from python import Python
from python.object import PythonObject

from geo_features.geom import (
    Point, Point2, Point3, Point4, 
    LineString, LineString2, LineString3, LineString4,
    Envelope, Envelope2, Envelope3, Envelope4,
)

from geo_features.test.helpers import assert_true

let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0


fn main() raises:
    test_envelope()


fn test_envelope() raises:
    print("# Envelope\n")

    test_constructors()
    # test_repr()
    # test_southwesterly_point()

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

    _ = Envelope[DType.int8, 2](Point[DType.int8, 2](lon, lat))
    _ = Envelope[DType.float64, 4](Point[DType.float64, 4](lon, lat, height, measure))

    # from LineString
     _ = Envelope2(
            LineString2(Point2(lon, lat), Point2(lon+1, lat+1), Point2(lon+2, lat+2),  Point2(lon+3, lat+3)
        )
    )

    _ = Envelope[DType.float64, 2](
        LineString[DType.float64, 2](
            Point[DType.float64, 2](lon, lat),
            Point[DType.float64, 2](lon+1, lat+1),
            Point[DType.float64, 2](lon+2, lat+2), 
            Point[DType.float64, 2](lon+3, lat+3),
            Point[DType.float64, 2](lon+4, lat+4),
            Point[DType.float64, 2](lon+5, lat+5)
        )
    )
    print("✅")


# fn test_repr() raises:
#     print("repr...")

#     let e = Envelope2(Point2(lon, lat))
#     assert_true(
#         e.__repr__()
#         == "Envelope[float32, 2](-108.68000030517578, 38.9739990234375,"
#         " -108.68000030517578, 38.9739990234375)",
#         "__repr__",
#     )

#     let e2 = Envelope2(
#         LineString2(Point2(lon, lat), Point2(lon+1, lat+1), Point2(lon+2, lat+2))
#     )
#     print(e2.__repr__())
#     # assert_true(
#     #     e2.__repr__()
#     #     == "Envelope[float32, 2](-108.68000030517578, 38.9739990234375, -108.68000030517578, 38.9739990234375)",
#     #     "__repr__"
#     # )


# fn test_southwesterly_point() raises:
#     print("southwesterly_point...")

#     let e = Envelope2(Point2(lon, lat))
#     let sw_pt = e.southwesterly_point()
#     assert_true(sw_pt.x() == lon, "southwesterly_point")
#     assert_true(sw_pt.y() == lat, "southwesterly_point")


# fn northeasterly_point() raises:
#     print("northeasterly_point...")

#     let e = Envelope2(Point2(lon, lat))
#     let sw_pt = e.northeasterly_point()
#     assert_true(sw_pt.x() == lon, "northeasterly_point")
#     assert_true(sw_pt.y() == lat, "northeasterly_point")
