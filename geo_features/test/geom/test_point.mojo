from python import Python
from python.object import PythonObject

from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.test.helpers import assert_true
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


fn test_repr() raises:
    print("# repr")
    let pt1 = Point2(lon, lat)
    assert_true(
        pt1.__repr__() == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
        "__repr__",
    )
    let pt2 = Point2(SIMD[DType.float64, 2](lon, lat))
    assert_true(
        pt2.__repr__() == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
        "__repr__",
    )


fn test_equality_ops() raises:
    print("# equality operators")

    let p2a = Point2(lon, lat)
    let p2b = Point2(lon, lat)
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
    assert_true(pt2.z() == 0, "p2.z() == 0")
    assert_true(pt2.m() == 0, "p2.m() == 0")

    # edge case: initialize a Point3 with a SIMD[4]
    let pt3 = Point3(SIMD[DType.float64, 4](lon, lat, height, measure))

    assert_true(pt3.x() == lon, "p3.x() == lon")
    assert_true(pt3.y() == lat, "p3.y() == lat")
    assert_true(pt3.z() == height, "p3.z() == height")
    assert_true(pt3.m() == measure, "p3.m() == measure")

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

    var pt4 = Point4(lon, lat, height, measure)
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
    let json = Python.import_module("json")
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
    let wkt = "POINT(-108.680 38.974)"
    try:
        let pt1 = Point2.from_wkt(wkt)
        assert_true(
            pt1.__repr__()
            == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
            "from_wkt()",
        )

        let pt2 = Point3.from_wkt(wkt)
        assert_true(
            pt2.__repr__()
            == "Point[4, float64](-108.68000000000001, 38.973999999999997, 0.0, 0.0)",
            "from_wkt()",
        )

        let pt3 = Point[2, DType.uint8].from_wkt(wkt)
        assert_true(pt3.__repr__() == "Point[2, uint8](148, 38)", "from_wkt())")

        let pt4 = Point[2, DType.float64].from_wkt(wkt)
        assert_true(
            pt4.__repr__()
            == "Point[2, float64](-108.68000000000001, 38.973999999999997)",
            "from_wkt()",
        )
    except:
        raise Error(
            "from_wkt(): Maybe failed to import_module of shapely? check venv's install"
            " packages."
        )
