from testing import assert_true, assert_false

from geo_features.geom.point import Point, Point2, Point3, Point4


def test_point():
    print("# Point\n")

    # constructor, __str__(), __eq__
    let p1 = Point[DType.float64, 2](-108.68, 38.01)
    let p1a = Point[DType.float64, 2](-108.68, 38.01)
    let p1b = Point[DType.float64, 2](-108.68, 38.01)

    print(p1.__str__(), "==", p1a.__str__())
    assert_true(p1 == p1a, "Point.__eq__() fail / L15")

    let p2 = Point[DType.int16, 2](8, 9)
    let p2b = Point[DType.int16, 2](8, 9)
    print(p2.__str__(), " == ", p2b.__str__())
    assert_true(p2 == p2b, "Point.__eq__() fail / L20")

    let p3 = Point[DType.int16, 2](3, 4)
    print(p2.__str__(), " != ", p2b.__str__())
    assert_true(p2 != p3, "Point.__eq__() fail / L24")

    let p4 =  Point4(-108.68, 38.01, 20., 3.14)
    let p4a = Point4(-108.68, 38.01, 20., 3.14)
    let p4b = Point4(-108.68, 38.01, 20., 4)

    print(p4.__str__(), " == ", p4a.__str__())
    assert_true(p4 == p4a, "Point.__eq__() fail / L31")

    print(p4.__str__(), " != ", p4b.__str__())
    assert_true(p4 != p4b, "Point.__ne__() fail / L34")

    print()
