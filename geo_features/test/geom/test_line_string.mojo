from testing import assert_true, assert_false
from python import Python
from python.object import PythonObject


from geo_features.geom.point import Point, Point2, Point3, Point4
from geo_features.geom.line_string import LineString, LineString2, LineString3, LineString4


let lon = -108.680
let lat = 38.974
let height = 8.0
let measure = 42.0


def test_line_string():
    # let points = [Point2(lon, lat), Point2(lon, lat), Point2(lon, lat),]
    let lstr = LineString2(Point2(lon, lat), Point2(lon, lat), Point2(lon, lat))
    assert_true(lstr.__len__() == 3)

