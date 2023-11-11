from utils.index import Index
from math.limit import inf, neginf
from sys.info import simdwidthof, simdbitwidth
from algorithm import vectorize
from algorithm.functional import parallelize
import math
from tensor import Tensor

from geo_features.geom import Point, LineString, Layout


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


@value
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
        for i in range(dims):
            coords[i] = point.coords[i]
            coords[i + dims] = point.coords[i]
        return Self {coords: coords}

    fn __init__(line_string: LineString[dims, dtype]) -> Self:
        """
        Construct Envelope of LineString.
        """
        let layout = line_string.memory_layout
        return Envelope[dims, dtype](layout)

    fn __init__(data: Layout[dims, dtype], num_workers: Int = 0) -> Self:
        """
        Construct Envelope from memory Layout.
        """
        # TODO: autotune for number of workers (oversubscribing dims across dims workers is a guess)?
        # TODO: autotune for nelts (simdwidthof[dtype] is a guess)?
        # TODO: autotune for new param: parallelize_length_cutoff- with less than a few thousand coordinates, it's faster on single core)
        # See bench_envelope.mojo

        # fill initial values of with inf/neginf at each position in the 2*n array

        alias n = 2 * dims
        var coords = Tensor[dtype](n, 1)

        @unroll
        for d in range(dims):
            coords[d] = Self.Inf  # min (southwest) values, start from inf.

        @unroll
        for d in range(dims, n):
            coords[d] = Self.NegInf  # max (northeast) values, start from neginf

        alias nelts = simdwidthof[dtype]()
        let num_features = data.coordinates.shape()[1]

        # vectorized load and min/max calculation for each of the dims
        @parameter
        fn min_max_task(dim: Int):
            @parameter
            fn min_max_simd[simd_width: Int](feature_idx: Int):
                let index = Index(dim, feature_idx)
                let vals = data.coordinates.simd_load[simd_width](index)
                let min = vals.reduce_min()
                if min < coords[dim]:
                    coords[dim] = min
                let max = vals.reduce_max()
                if max > coords[dims + dim]:
                    coords[dims + dim] = max

            vectorize[nelts, min_max_simd](num_features)

        if num_workers > 0:
            parallelize[min_max_task](dims, num_workers)
        else:
            for d in range(dims):
                min_max_task(d)

        let result_coords: Self.CoordsT = coords.simd_load[2 * dims]()
        return Self {coords: result_coords}

    fn __repr__(self) -> String:
        var res = "Envelope[" + dtype.__str__() + ", " + String(dims) + "]("
        for i in range(2 * dims):
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
