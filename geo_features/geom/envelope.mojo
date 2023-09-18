from geo_features.geom import Point, LineString

from utils.index import Index
from math.limit import inf, neginf
from sys.info import simdwidthof
from algorithm.functional import vectorize

# alias BBox = Envelope

alias Envelope2 = Envelope[DType.float32, 2]
"""
Alias for 2D Envelope with dtype: float32.
"""

alias Envelope3 = Envelope[DType.float32, 4]
"""
Alias for 3D Envelope with dtype float32. Note: is backed by SIMD vector of size 4 (must be power of two).
"""

alias Envelope4 = Envelope[DType.float32, 4]
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
        Construct Envelope of Point.
        """
        var coords = Self.CoordsT()
        for i in range(0, dims):
            coords[i] = point.coords[i]
            coords[i + dims] = point.coords[i]
        return Self {coords: coords}

    fn __init__(line_string: LineString[dtype, dims]) -> Self:
        """
        Construct Envelope of LineString.
        """
        var coords = Self.CoordsT()
        var max = neginf[dtype]()
        var min = inf[dtype]()

        # simd_load each dimension from the tensor to find the min/max values?
        # FIXME

        @parameter
        fn min_max_simd[size: Int](i: Int):
            print("size: ", size)
            let x_vals = line_string.coords.simd_load[size](Index(i, 0))
            print("i:", i, " x_vals: ", x_vals)

        let n = line_string.__len__()
        print(dtype, simdwidthof[dtype]())
        vectorize[simdwidthof[dtype](), min_max_simd](n)

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
        # TODO min_z
        return self.coords[0]

    fn max_z(self) -> SIMD[dtype, 1]:
        # TODO max_z
        return self.coords[0]

    fn min_m(self) -> SIMD[dtype, 1]:
        # TODO min_m
        return self.coords[0]

    fn max_m(self) -> SIMD[dtype, 1]:
        # TODO max_m
        return self.coords[0]

    fn southwesterly_point(self) -> Point[dtype, dims]:
        let coords = self.coords.slice[dims](0)
        return Point[dtype, dims](coords)

    fn northeasterly_point(self) -> Point[dtype, dims]:
        let coords = self.coords.slice[dims](dims)
        return Point[dtype, dims](coords)
