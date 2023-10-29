from geo_features.geom import Point, LineString, Layout

from utils.index import Index
from math.limit import inf, neginf
from sys.info import simdwidthof, simdbitwidth
from algorithm import vectorize
import math

alias Envelope2 = Envelope[2, DType.float64]
"""
Alias for 2D Envelope with dtype float64.
"""

alias Envelope3 = Envelope[4, DType.float64]
"""
Alias for 3D Envelope with dtype float64. Note: is backed by SIMD vector of size 2*4 (SIMD must be power of two).
"""

alias Envelope4 = Envelope[4, DType.float64]
"""
Alias for 4D Envelope with dtype float64.
"""


@register_passable("trivial")
struct Envelope[dims: Int = 2, dtype: DType = DType.float64]:
    """
    Envelope aka Bounding Box.

    > "The value of the bbox member must be an array of length 2*n where n is the number of dimensions represented in the
    contained geometries, with all axes of the most southwesterly point followed by all axes of the more northeasterly
    point."  https://datatracker.ietf.org/doc/html/rfc7946
    """

    alias CoordsT = SIMD[dtype, 2 * dims]
    alias NegInf = neginf[dtype]()
    alias Inf = inf[dtype]()

    var coords: Self.CoordsT

    fn __init__(point: Point[dims, dtype]) -> Self:
        """
        Construct Envelope of Point.
        """
        var coords = Self.CoordsT()

        @unroll
        for i in range(0, dims):
            coords[i] = point.coords[i]
            coords[i + dims] = point.coords[i]
        return Self {coords: coords}

    fn __init__(line_string: LineString[dims, dtype]) -> Self:
        """
        Construct Envelope of LineString.
        """
        let layout = line_string.memory_layout
        return Envelope[dims, dtype](layout)

    fn __init__(memory_layout: Layout[dims, dtype]) -> Self:
        """
        Construct Envelope of Layout.
        """
        var coords = Self.CoordsT()

        # fill initial values of with inf/neginf at each position in the 2*n array

        # min (southwest) values, start from inf.
        @unroll
        for d in range(0, dims):
            coords[d] = Self.Inf

        # max|northwest values, start from neginf
        @unroll
        for d in range(dims, 2 * dims):
            coords[d] = Self.NegInf

        # print("before worker", coords)

        alias nelts = simdwidthof[dtype]()
        # print("simdwidthof", dtype, ":", nelts, "fit in simdbitwidth", simdbitwidth())

        fn worker(dim: Int):
            @parameter
            fn min_max_simd[simd_width: Int](feature_idx: Int):
                """
                vectorized load and min/max calculation for each of the dims
                """
                # print(
                #     "dim:", dim, "simd_width:", simd_width, "feature_idx:", feature_idx
                # )
                let vals = memory_layout.coordinates.simd_load[simd_width](feature_idx)
                # print("vals", vals)
                let min = vals.reduce_min()
                # print("min of vals:", vals, min)
                if min < coords[dim]:
                    coords[dim] = min
                let max = vals.reduce_max()
                # print("max of vals:", vals, max)
                if max > coords[dims + 2 * dim]:
                    coords[dims + dim] = max

            let num_features = memory_layout.coordinates.shape()[dim]
            vectorize[nelts, min_max_simd](num_features)

        for d in range(0, dims):
            worker(d)

        # print(coords)
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

    fn southwesterly_point(self) -> Point[dims, dtype]:
        let coords = self.coords.slice[dims](0)
        return Point[dims, dtype](coords ^)

    fn northeasterly_point(self) -> Point[dims, dtype]:
        let coords = self.coords.slice[dims](dims)
        return Point[dims, dtype](coords ^)
