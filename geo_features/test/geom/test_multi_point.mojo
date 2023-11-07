from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index

from geo_features.geom import Point, Point2, Point3, Point4
from geo_features.geom import MultiPoint, MultiPoint2, MultiPoint3, MultiPoint4

from geo_features.test.helpers import assert_true
from geo_features.test.constants import lat, lon, height, measure


fn main() raises:
    test_multi_point()


fn test_multi_point() raises:
    test_constructors()
    test_mem_layout()
    test_get_item()
    test_equality_ops()
    test_is_empty()
    test_repr()
    test_str()
    test_wkt()
    test_json()
    test_from_json()
    test_from_wkt()

    print()


fn test_constructors() raises:
    print("# variadic list constructor")

    let mpt = MultiPoint2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(mpt[0] == Point2(lon, lat), "variadic list constructor")
    assert_true(mpt[1] == Point2(lon, lat), "variadic list constructor")
    assert_true(mpt[2] == Point2(lon, lat + 1), "variadic list constructor")
    assert_true(mpt.__len__() == 3, "variadic list constructor")

    print("# vector constructor")

    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    _ = MultiPoint2(points_vec)


fn test_mem_layout() raises:
    """
    Test if MultiPoint fills the Layout struct correctly.
    """
    print("# mem layout")

    # equality check each point by indexing into the MultiPoint.
    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let mpt2 = MultiPoint2(points_vec)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        assert_true(mpt2[n] == expect_pt, "test_mem_layout")

    let layout = mpt2.memory_layout

    # offsets fields are empty in MultiPoint because of using geo_arrows "struct coordinate representation"
    assert_true(
        layout.geometry_offsets.num_elements() == 0, "geo_arrow geometry_offsets"
    )
    assert_true(layout.part_offsets.num_elements() == 0, "geo_arrow part_offsets")
    assert_true(layout.ring_offsets.num_elements() == 0, "geo_arrow ring_offsets")


fn test_get_item() raises:
    print("# get_item")
    var points_vec = DynamicVector[Point2](10)
    for n in range(10):
        points_vec.push_back(Point2(lon + n, lat - n))
    let mpt = MultiPoint2(points_vec)
    for n in range(10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = mpt[n]
        assert_true(got_pt == expect_pt, "get_item")


fn test_equality_ops() raises:
    print("# equality operators")

    # partial simd_load (n - i < nelts)
    let mpt1 = MultiPoint2(
        Point2(1, 2), Point2(3, 4), Point2(5, 6), Point2(7, 8), Point2(9, 10)
    )
    let mpt2 = MultiPoint2(
        Point2(1.1, 2.1),
        Point2(3.1, 4.1),
        Point2(5.1, 6.1),
        Point2(7.1, 8.1),
        Point2(9.1, 10.1),
    )
    assert_true(mpt1 != mpt2, "partial simd_load (n - i < nelts)")

    # partial simd_load (n - i < nelts)
    let mpt5 = MultiPoint[2, DType.float32](
        Point[2, DType.float32](1, 2),
        Point[2, DType.float32](5, 6),
        Point[2, DType.float32](10, 11),
    )
    let mpt6 = MultiPoint[2, DType.float32](
        Point[2, DType.float32](1, 2),
        Point[2, DType.float32](5, 6),
        Point[2, DType.float32](10, 11.1),
    )
    assert_true(mpt5 != mpt6, "partial simd_load (n - i < nelts) (b)")

    let mpt7 = MultiPoint[2, DType.float16](
        Point[2, DType.float16](1, 2),
        Point[2, DType.float16](5, 6),
        Point[2, DType.float16](10, 11),
    )
    let mpt8 = MultiPoint[2, DType.float16](
        Point[2, DType.float16](1, 2),
        Point[2, DType.float16](5, 6),
        Point[2, DType.float16](10, 11.1),
    )
    assert_true(mpt7 != mpt8, "__ne__")

    var points_vec2 = DynamicVector[Point2](10)
    for n in range(10):
        points_vec2.push_back(Point2(lon + n, lat - n))
    let mpt9 = MultiPoint2(points_vec2)
    let mpt10 = MultiPoint2(points_vec2)
    assert_true(mpt9 == mpt10, "__eq__")
    assert_true(mpt9 != mpt2, "__ne__")

    let mpt11 = MultiPoint2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    let mpt12 = MultiPoint2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(mpt11 == mpt12, "__eq__")
    assert_true(mpt9 != mpt12, "__ne__")


fn test_is_empty() raises:
    print("# is_empty")
    let empty_lstr = MultiPoint2()
    assert_true(empty_lstr.is_empty() == True, "is_empty()")


fn test_repr() raises:
    print("# __repr__")
    let mpt = MultiPoint2(Point2(lon, lat), Point2(lon + 1, lat + 1))
    let s = mpt.__repr__()
    assert_true(s == "MultiPoint[2, float64](2 points)", "__repr__")


fn test_str() raises:
    print("# __str__")
    let mpt = MultiPoint2(Point2(lon, lat), Point2(lon + 1, lat + 1))
    assert_true(mpt.__str__() == mpt.wkt(), "__str__")


fn test_wkt() raises:
    print("# wkt")
    let mp = MultiPoint2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat + 1))
    assert_true(
        mp.wkt()
        == "MULTIPOINT(-108.68000000000001 38.973999999999997, -108.68000000000001"
        " 38.973999999999997, -108.68000000000001 39.973999999999997)",
        "wkt",
    )


fn test_json() raises:
    print("# json")
    let mpt = MultiPoint2(Point2(lon, lat), Point2(lon + 1, lat + 1))
    assert_true(
        mpt.json()
        == '{"type":"MultiPoint","coordinates":[[-108.68000000000001,38.973999999999997],[-107.68000000000001,39.973999999999997]]}',
        "json",
    )


fn test_from_json() raises:
    print("# from_json (⚠️  not implemented)")
    let json_str = String(
        '{"type":"MultiPoint","coordinates":[[42.0,38.9739990234375],[42.0,38.9739990234375]]}'
    )
    let json = Python.import_module("json")
    let json_dict = json.loads(json_str)

    try:
        _ = MultiPoint2.from_json(json_dict)
        raise Error("unreachable")
    except e:
        assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO


fn test_from_wkt() raises:
    print("# from_wkt (⚠️  not implemented)")
    # try:
    #     _ = MultiPoint2.from_wkt("")
    #     raise Error("unreachable")
    # except e:
    #     assert_true(e.__str__() == "not implemented", "unexpected error value")  # TODO
