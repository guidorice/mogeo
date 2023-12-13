@register_passable("trivial")
struct CoordDims(Stringable):
    """
    Enum for encoding the OGC/WKT variants of Points.
    """

    # TODO: use a real enum here, when mojo supports.

    var value: SIMD[DType.uint8, 1]

    alias Point = CoordDims(252)
    """
    2 dimensional Point.
    """
    alias PointZ = CoordDims(253)
    """
    3 dimensional Point, has height or altitude (Z).
    """
    alias PointM = CoordDims(254)
    """
    3 dimensional Point, has measure (M).
    """
    alias PointZM = CoordDims(255)
    """
    4 dimensional Point, has height and measure  (ZM)
    """

    fn __init__(value: Int) -> Self:
        return Self {value: value}

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __str__(self) -> String:
        """
        Convert to string, using WKT point variants.
        """
        if self == CoordDims.Point:
            return "Point"
        if self == CoordDims.PointZ:
            return "Point Z"
        if self == CoordDims.PointM:
            return "Point M"
        if self == CoordDims.PointZM:
            return "Point ZM"
        return "Point"
