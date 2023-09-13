from testing import assert_true, assert_false
from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index

from benchmark import Benchmark

from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.geom.line_string import LineString, LineString2, LineString3, LineString4


let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0

def test_line_string():
    print("# LineString")

    print("variadic list constructor...")
    let lstr = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat))
    assert_true(lstr.__len__() == 3)
    print(lstr.__repr__())
    print()

    print("vector constructor...")
    var points_vec = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec.push_back( Point2(lon + n, lat - n) )
    let lstr2 = LineString2(points_vec)
    assert_true(lstr2.__len__() == 10)
    print()

    print("get_item...")
    for n in range(0, 10):
        let expect_pt = Point2(lon + n, lat - n)
        let got_pt = lstr2[n]
        assert_true(got_pt == expect_pt, "lstr2 == expect_pt")
    print(lstr2.__repr__())
    print()

    print("equality operators...")

    # partial simd_load (n - i < nelts)
    let lstr8 = LineString2(Point2(1,2),     Point2(3,4),     Point2(5, 6),     Point2(7, 8), Point2(9, 10))
    let lstr9 = LineString2(Point2(1.1,2.1), Point2(3.1,4.1), Point2(5.1, 6.1), Point2(7.1, 8.1), Point2(9.1, 10.1))
    assert_true(lstr8 != lstr9, "lstr8 == lstr9")

    # partial simd_load (n - i < nelts)
    let lstr10 = LineString[DType.float32, 2](Point[DType.float32, 2](1,2), Point[DType.float32, 2](5,6), Point[DType.float32, 2](10,11))
    let lstr11 = LineString[DType.float32, 2](Point[DType.float32, 2](1,2), Point[DType.float32, 2](5,6), Point[DType.float32, 2](10,11.1))
    assert_true(lstr10 != lstr11, "lstr10 != lstr11")

    let lstr12 = LineString[DType.float16, 2](Point[DType.float16, 2](1,2), Point[DType.float16, 2](5,6), Point[DType.float16, 2](10,11))
    let lstr13 = LineString[DType.float16, 2](Point[DType.float16, 2](1,2), Point[DType.float16, 2](5,6), Point[DType.float16, 2](10,11.1))
    assert_true(lstr10 != lstr11, "lstr12 != lstr12")

    var points_vec2 = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec2.push_back(Point2(lon + n, lat - n))
    let lstr3 = LineString2(points_vec2)
    assert_true(lstr2 == lstr3, "lstr2 == lstr3")

    let lstr4 = LineString2(Point2(lon, lat), Point2(lon, lat))
    assert_true(lstr != lstr4, "lstr2 != lstr3")

    let lstr5 = LineString2(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr4 != lstr5, "lstr2 != lstr3")


    var points_vec_big = DynamicVector[Point2](300000)
    for n in range(0, 300000):
        points_vec_big.push_back(Point2(n, n+1))
    let lstr20 = LineString2(points_vec_big)
    let lstr21 = LineString2(points_vec_big)
    assert_true(lstr20 == lstr21, "lstr9 == lstr10")

    @parameter
    fn bench():
       _ = lstr20 == lstr21 

    print("memcmp equality check:")
    let ns1 = Benchmark(2, 1000000, 1000000, 1000000).run[bench]()

    @parameter
    fn bench2():
       _ = lstr20._sloweq(lstr21)
    print("procedural equality check:")
    let ns2 = Benchmark(2, 1000000, 1000000, 1000000).run[bench2]()

    print(ns1, " vs ", ns2, ns2.__truediv__(ns1), "X speedup")
