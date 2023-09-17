from geo_features.geom.point import Point


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
        Create Envelope from Point.
        """
        var coords = Self.CoordsT()
        for i in range(0, dims):
            coords[i] = point.coords[i]
            coords[i + dims] = point.coords[i + dims]
        return Self {coords: coords}
