from .enums import CoordDims
from .envelope import Envelope


trait Dimensionable:
    fn dims(self) -> Int:
        ...

    fn has_height(self) -> Bool:
        ...

    fn has_measure(self) -> Bool:
        ...

    fn set_ogc_dims(inout self, ogc_dims: CoordDims):
        """
        Setter for ogc_dims enum. May be useful if the Point constructor with variadic list of coordinate values.
        (Point Z vs Point M is ambiguous).
        """
        ...


trait Emptyable:
    @staticmethod
    fn empty(dims: CoordDims = CoordDims.Point) -> Self:
        ...

    fn is_empty(self) -> Bool:
        ...


trait Geometric(Dimensionable):
    ...
    # TODO: Geometric trait seems to require parameter support on Traits (TBD mojo version?)

    # fn envelope(self) -> Envelope[dtype]:
    # fn contains(self, other: Self) -> Bool
    # fn contains(self, other: Self) -> Bool
    # fn intersects(self, other: Self) -> Bool
    # fn overlaps(self, other: Self) -> Bool
    # fn disjoint(self, other: Self) -> Bool
    # fn touches(self, other: Self) -> Bool
    # fn intersection(self, other: Self) -> Self
    # fn union(self, other: Self) -> Self
    # fn difference(self, other: Self) -> Self
    # fn buffer(self, size: SIMD[dtype, 1]) -> Self
    # fn convex_hull(self) -> Polygon[dtype]
    # fn simplify(self) -> Self
    # fn centroid(self) -> SIMD[dtype, 1]
    # fn area(self) -> SIMD[dtype, 1]
    # fn length(self) -> SIMD[dtype, 1]
    # fn translate(self, SIMD[dtype, simd_dims]) -> Self
    # fn rotate(self, degrees: SIMD[dtype, 1]) -> Self
