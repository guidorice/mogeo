from .enums import CoordDims


trait Dimensionable:
    fn dims(self) -> Int:
        ...

trait Zeroable:
    @staticmethod
    fn zero(dims: CoordDims = CoordDims.Point) -> Self:
        ...

trait Geometric(Dimensionable):
    """
    TODO: geometric trait

    contains(Geometry): Tests if one geometry contains another.
    intersects(Geometry): Tests if two geometries intersect.
    overlaps(Geometry): Tests if two geometries overlap, i.e. their intersection results in a geometry of the same dimension and not just a point/line.
    disjoint(Geometry): Tests if two geometries are disjoint, i.e. they do not intersect.
    touches(Geometry): Tests if two geometries touch, i.e. their intersection is just one point.
    intersection(Geometry): Returns a geometry representing the shared portion of the two geometries.
    union(Geometry): Returns a geometry representing all points of the two geometries.
    difference(Geometry): Returns a geometry representing all points of one geometry that do not intersect with another.
    buffer(double): Returns an area around the geometry wider by a given distance.
    convexHull(): Returns the convex hull of a geometry, i.e. the shape enclosing all outer points.
    simplify(double): Returns a simplified version of a geometry using the Douglas-Peucker algorithm within a given tolerance.
    centroid(): Returns the geometric center point of a geometry.
    getArea(): Returns the area of a polygonal geometry.
    getLength(): Returns the length of a linear geometry.
    translate(double, double): Moves a geometry by given offsets.
    rotate(double): Rotates a geometry around a point by a given angle.

    """
    ...