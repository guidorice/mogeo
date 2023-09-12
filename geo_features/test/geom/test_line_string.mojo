from testing import assert_true, assert_false
from python import Python
from python.object import PythonObject
from utils.vector import DynamicVector
from utils.index import Index


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
    var points_vec2 = DynamicVector[Point2](10)
    for n in range(0, 10):
        points_vec2.push_back(Point2(lon + n, lat - n))
    let lstr3 = LineString2(points_vec2)
    assert_true(lstr2 == lstr3, "lstr2 == lstr3")

    let lstr4 = LineString2(Point2(lon, lat), Point2(lon, lat))
    assert_true(lstr != lstr4, "lstr2 != lstr3")

    let lstr5 = LineString2(Point2(42, lat), Point2(lon, lat))
    assert_true(lstr4 != lstr5, "lstr2 != lstr3")
