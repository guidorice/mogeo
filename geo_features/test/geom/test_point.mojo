from python import Python
from python.object import PythonObject

from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.test.helpers import assert_true, assert_false

let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0


def main():
    print("# Point\n")

    test_constructors()
    test_repr()
    test_equality_ops()
    test_getters()
    test_wkt()
    test_json()
    test_static_methods()
    test_from_json()
    test_from_wkt()

    print()


fn test_constructors():
    print("constructors, aliases:")
    # aliases
    _ = Point2(lon, lat)
    _ = Point2(SIMD[DType.float32, 2](lon, lat))
    _ = Point3(lon, lat, height)
    _ = Point4(lon, lat, height, measure)

    # constructors, parameters
    _ = Point[DType.int32, 2](lon, lat)
    _ = Point[DType.float64, 2](lon, lat)
    _ = Point[DType.float64, 2](lon, lat)
    _ = Point3(SIMD[DType.float32, 4](lon, lat, height))
    _ = Point4(SIMD[DType.float32, 4](lon, lat, height, measure))

    print("✅")


fn test_repr() raises:
    print("repr...")
    let pt1 = Point2(lon, lat)
    assert_true(
        pt1.__repr__() == "Point[float32, 2](-108.68000030517578, 38.9739990234375)",
        "__repr__",
    )
    let pt2 = Point2(SIMD[DType.float32, 2](lon, lat))
    assert_true(
        pt2.__repr__() == "Point[float32, 2](-108.68000030517578, 38.9739990234375)",
        "__repr__",
    )


fn test_equality_ops() raises:
    print("equality operators...")
    let p2a = Point2(lon, lat)
    let p2b = Point2(lon, lat)
    assert_true(p2a == p2b, "__eq__")

    let p2i = Point[DType.int16, 2](lon, lat)
    let p2ib = Point[DType.int16, 2](lon, lat)
    assert_true(p2i == p2ib, "__eq__")

    let p2ic = Point[DType.int16, 2](lon + 1, lat)
    assert_true(p2i != p2ic, "__ne_")

    let p4 = Point4(lon, lat, height, measure)
    let p4a = Point4(lon, lat, height, measure)
    let p4b = Point4(lon + 0.001, lat, height, measure)
    assert_true(p4 == p4a, "__eq__")
    assert_true(p4 != p4b, "__eq__")
    print("✅")


fn test_getters() raises:
    print("getters...")
    let pt2 = Point2(lon, lat)
    assert_true(pt2.x() == lon, "p2.x() == lon")
    assert_true(pt2.y() == lat, "p2.y() == lat")
    assert_true(pt2.z() == 0, "p2.z() == 0")
    assert_true(pt2.m() == 0, "p2.m() == 0")

    # edge case: initialize a Point3 with a SIMD[4]
    let pt3 = Point3(SIMD[DType.float32, 4](lon, lat, height, measure))

    assert_true(pt3.x() == lon, "p3.x() == lon")
    assert_true(pt3.y() == lat, "p3.y() == lat")
    assert_true(pt3.z() == height, "p3.z() == height")
    assert_true(pt3.m() == measure, "p3.m() == measure")

    let p4 = Point4(lon, lat, height, measure)
    assert_true(p4.x() == lon, "p4.x() == lon")
    assert_true(p4.y() == lat, "p4.y() == lat")
    assert_true(p4.z() == height, "p4.z() == height")
    assert_true(p4.m() == measure, "p4.m() == measure")
    print("✅")


fn test_json() raises:
    print("json...")
    let pt2 = Point2(lon, lat)
    print(pt2.json())
    assert_true(
        pt2.json()
        == '{"type":"Point","coordinates":[-108.68000030517578,38.9739990234375]}',
        "json()",
    )
    let pt3 = Point3(lon, lat, height)
    assert_true(
        pt3.json()
        == '{"type":"Point","coordinates":[-108.68000030517578,38.9739990234375,8.0]}',
        "json()",
    )

    let pt4 = Point4(lon, lat, height, measure)
    assert_true(
        pt4.json()
        == '{"type":"Point","coordinates":[-108.68000030517578,38.9739990234375,8.0]}',
        "json()",
    )
    print("✅")


fn test_wkt() raises:
    print("wkt...")

    let pt4 = Point4(lon, lat, height, measure)
    assert_true(
        pt4.wkt() == "POINT(-108.68000030517578 38.9739990234375 8.0 42.0)", "p4.wkt()"
    )

    let p2i = Point[DType.int32, 2](lon, lat)
    assert_true(p2i.wkt() == "POINT(-108 38)", "p2i.wkt()")
    print("✅")


fn test_static_methods() raises:
    print("static methods...")
    print("zero...")
    let pt2 = Point2.zero()
    assert_true(pt2.x() == 0, "zero().x()")
    assert_true(pt2.y() == 0, "zero().y()")

    let pt4 = Point4.zero()
    assert_true(pt4.x() == 0, "zero().x()")
    assert_true(pt4.y() == 0, "zero().y()")
    assert_true(pt4.z() == 0, "zero().z()")
    assert_true(pt4.m() == 0, "zero().m()")

    let pti = Point[DType.int8, 2].zero()
    assert_true(pti.x() == 0, "zero().x()")
    assert_true(pti.y() == 0, "zero().y()")

    print("✅")


fn test_from_json() raises:
    print("from_json...")
    let json_str = String('{"type": "Point","coordinates": [102.0, 3.5]}')
    let json = Python.import_module("json")
    let json_dict = json.loads(json_str)

    var from_json_pt = Point[DType.float64, 2].from_json(json_dict)
    print(from_json_pt.__repr__())
    var from_json_pt2 = Point2.from_json(json_dict)
    print(from_json_pt2.__repr__())
    var from_json_pt3 = Point[DType.uint8, 2].from_json(json_dict)
    print(from_json_pt3.__repr__())
    print("✅")

    from_json_pt = Point[DType.float64, 2].from_json(json_str)
    print(from_json_pt.__repr__())
    from_json_pt2 = Point2.from_json(json_dict)
    print(from_json_pt2.__repr__())
    from_json_pt3 = Point[DType.uint8, 2].from_json(json_dict)
    print(from_json_pt3.__repr__())
    print("✅")


fn test_from_wkt() raises:
    print("from_wkt...")
    let wkt = "POINT(-108.680 38.974)"
    try:
        let wkt_pt1 = Point2.from_wkt(wkt)
        print(wkt_pt1.__repr__())
        let wkt_pt2 = Point3.from_wkt(wkt)
        print(wkt_pt2.__repr__())
        let wkt_pt3 = Point[DType.uint8, 2].from_wkt(wkt)
        print(wkt_pt3.__repr__())
        let wkt_pt4 = Point[DType.float64, 2].from_wkt(wkt)
        print(wkt_pt4.__repr__())
    except:
        raise Error(
            "from_wkt(): Maybe failed to import_module of shapely? check venv's install"
            " packages."
        )
    print("✅")
