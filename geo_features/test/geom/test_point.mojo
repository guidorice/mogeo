from testing import assert_true, assert_false

from geo_features.geom.point import Point, Point2, Point3, Point4

let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0


def test_point():
    print("# Point\n")

    print("constructors, aliases, __repr__:")
    print("Point2:")
    let alias_p2 = Point2(lon, lat)
    print(alias_p2.__repr__())
    let alias_p2b = Point2(SIMD[DType.float32, 2](lon, lat))
    print(alias_p2b.__repr__())

    print("Point3:")
    let alias_p3 = Point3(lon, lat, height)
    print(alias_p3.__repr__())
    let alias_p3b = Point3(SIMD[DType.float32, 4](lat, lon, height))
    print(alias_p3b.__repr__())

    print("Point4:")
    let alias_p5 = Point4(lon, lat, height, measure)
    let alias_p6 = Point4(SIMD[DType.float32, 4](lon, lat, height, measure))

    print("Point[dtype, size]:")
    let p2 = Point[DType.float64, 2](lon, lat)
    let p2a = Point[DType.float64, 2](lon, lat)
    let p2b = Point[DType.float64, 2](lon, lat)
    print()

    print("equality operators...")

    print(p2.__repr__(), "==", p2a.__repr__())
    assert_true(p2 == p2a, "p2 == p2a")

    let p2i = Point[DType.int16, 2](lon, lat)
    let p2ib = Point[DType.int16, 2](lon, lat)
    print(p2i.__repr__(), "==", p2ib.__repr__())
    assert_true(p2i == p2ib, "p2i == p2ib")

    let p2ic = Point[DType.int16, 2](lon + 1, lat)
    print(p2i.__repr__(), "!=", p2ic.__repr__())
    assert_true(p2i != p2ic, "p2i != p2ic")

    let p4 = Point4(lon, lat, height, measure)
    let p4a = Point4(lon, lat, height, measure)
    let p4b = Point4(lon + 0.001, lat, height, measure)

    print(p4.__repr__(), "==", p4a.__repr__())
    assert_true(p4 == p4a, "p4 == p4a")

    print(p4.__repr__(), "!=", p4b.__repr__())
    assert_true(p4 != p4b, "p4 != p4b")
    print()

    print("getters...")
    assert_true(p2.x() == lon, "p2.x() == lon")
    assert_true(p2.y() == lat, "p2.y() == lat")
    assert_true(p2.z() == 0, "p2.z() == 0")
    assert_true(p2.m() == 0, "p2.m() == 0")

    assert_true(alias_p3.x() == lon, "p3.x() == lon")
    assert_true(alias_p3.y() == lat, "p3.y() == lat")
    assert_true(alias_p3.z() == height, "p3.z() == height")
    assert_true(alias_p3.m() == 0, "p3.m() == 0")

    assert_true(p4.x() == lon, "p4.x() == lon")
    assert_true(p4.y() == lat, "p4.y() == lat")
    assert_true(p4.z() == height, "p4.z() == height")
    assert_true(p4.m() == measure, "p4.m() == measure")
    print()

    print("wkt...")
    print(p4.wkt())
    assert_true(
        p4.wkt() == "POINT(-108.68000030517578 38.9739990234375 8.0 42.0)", "p4.wkt()"
    )
    print(p2i.wkt())
    assert_true(p2i.wkt() == "POINT(-108 38)", "p2i.wkt()")
    print()

    print("geojson...")
    print(p2.json())
    assert_true(
        p2.json()
        == '{"type": "Point", "coordinates": [-108.68000000000001,'
        " 38.973999999999997]}",
        "p2.json()",
    )
    print(alias_p3.json())
    assert_true(
        alias_p3.json()
        == '{"type": "Point", "coordinates": [-108.68000030517578, 38.9739990234375,'
        " 8.0]}",
        "p3.json()",
    )
    print(p4.json())
    assert_true(
        p4.json()
        == '{"type": "Point", "coordinates": [-108.68000030517578, 38.9739990234375,'
        " 8.0]}",
        "p4.json()",
    )
    print()

    print("static methods...")
    let from_json_pt = Point2.from_json()
    print(from_json_pt.wkt())

def main():
    test_point()
