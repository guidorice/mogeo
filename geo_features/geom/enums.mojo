@value
@register_passable("trivial")
struct CoordDims(Stringable, Sized):
    """
    Enum for encoding the OGC/WKT variants of Points.
    """

    # TODO: use a real enum here, when mojo supports.

    var value: SIMD[DType.uint8, 1]

    alias Point = CoordDims(100)
    """
    2 dimensional Point.
    """
    alias PointZ = CoordDims(101)
    """
    3 dimensional Point, has height or altitude (Z).
    """
    alias PointM = CoordDims(102)
    """
    3 dimensional Point, has measure (M).
    """
    alias PointZM = CoordDims(103)
    """
    4 dimensional Point, has height and measure  (ZM)
    """

    alias PointND = CoordDims(104)
    """
    N-dimensional Point, number of dimensions from constructor.
    """

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        """
        Convert to string, using WKT point variants.
        """
        if self == CoordDims.Point:
            return "Point"
        elif self == CoordDims.PointZ:
            return "Point Z"
        elif self == CoordDims.PointM:
            return "Point M"
        elif self == CoordDims.PointZM:
            return "Point ZM"
        else:
            return "Point ND"

    fn __len__(self) -> Int:
        if self == CoordDims.Point:
            return 2
        elif self == CoordDims.PointM or self == CoordDims.PointZ:
            return 3
        elif self == CoordDims.PointZM:
            return 4
        else:
            return self.value.to_int()

    fn has_height(self) -> Bool:
        return (self == CoordDims.PointZ) or (self == CoordDims.PointZM)

    fn has_measure(self) -> Bool:
        return (self == CoordDims.PointM) or (self == CoordDims.PointZM)
