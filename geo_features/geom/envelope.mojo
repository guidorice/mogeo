from geo_features.geom.point import Point

alias BBox = Envelope

alias Envelope2 = Envelope[DType.float32, 2]
"""
Alias for 2D Envelope with dtype: float32.
"""

alias Envelope3 = Envelope[DType.float32, 4]
"""
Alias for 3D Envelope with dtype float32. Note: is backed by SIMD vector of size 4 (must be power of two).
"""

alias Envelope4 = Point[DType.float32, 4]
"""
Alias for 4D Envelope with dtype float32.
"""


@register_passable("trivial")
struct Envelope[dtype: DType, dims: Int]:
    """
    Envelope / Bounding Box

    modules/core/src/main/java/org/locationtech/jts/geom/Envelope.java

    > The value of the bbox member must be an array of length 2*n where n is the number of dimensions represented in the
    contained geometries, with all axes of the most southwesterly point followed by all axes of the more northeasterly
    point.

    https://datatracker.ietf.org/doc/html/rfc7946#section-5
    """

    alias CoordsT = SIMD[dtype, 2 * dims]

    var coords: Self.CoordsT

    fn __init__(point: Point[dtype, dims]) -> Self:
        """
        Create Envelope of Point.
        """
        var coords = Self.CoordsT()
        for i in range(0, dims):
            coords[i] = point.coords[i]
            coords[i + dims] = point.coords[i]
        return Self {coords: coords}

    fn __repr__(self) -> String:
        var res = "Envelope[" + dtype.__str__() + ", " + String(dims) + "]("
        for i in range(0, 2 * dims):
            res += self.coords[i]
            if i < 2 * dims - 1:
                res += ", "
        res += ")"
        return res

    fn min_x(self) -> SIMD[dtype, 1]:
        # TODO min_x
        return self.coords[0]

    fn max_x(self) -> SIMD[dtype, 1]:
        # TODO max_x
        return self.coords[0]

    fn min_y(self) -> SIMD[dtype, 1]:
        # TODO min_y
        return self.coords[0]

    fn max_y(self) -> SIMD[dtype, 1]:
        # TODO max_y
        return self.coords[0]

    fn min_z(self) -> SIMD[dtype, 1]:
        # TODO min_x
        return self.coords[0]

    fn max_z(self) -> SIMD[dtype, 1]:
        # TODO max_x
        return self.coords[0]

    fn southwesterly_point() -> SIMD[dtype, 2]:
        pass

    fn northeasterly_point() -> SIMD[dtype, 2]:
        pass
