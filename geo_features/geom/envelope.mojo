from utils.index import Index
from math.limit import inf, neginf, max_finite, min_finite

from sys.info import simdwidthof, simdbitwidth
from algorithm import vectorize
from algorithm.functional import parallelize
import math
from tensor import Tensor

from geo_features.geom.empty import empty_value, is_empty
from geo_features.geom.point import Point
from geo_features.geom.enums import CoordDims
from geo_features.geom.layout import Layout
from geo_features.geom.traits import Geometric, Emptyable
from geo_features.geom.empty import empty_value, is_empty

@value
@register_passable("trivial")
struct Envelope[dtype: DType](
    Geometric,
    Emptyable,
):
    """
    Envelope aka Bounding Box.

    > "The value of the bbox member must be an array of length 2*n where n is the number of dimensions represented in
    the contained geometries, with all axes of the most southwesterly point followed by all axes of the more
    northeasterly point." GeoJSON spec https://datatracker.ietf.org/doc/html/rfc7946
    """

    alias point_simd_dims = 4
    alias envelope_simd_dims = 8
    alias PointCoordsT = SIMD[dtype, Self.point_simd_dims]
    alias PointT = Point[dtype]
    alias x_index = 0
    alias y_index = 1
    alias z_index = 2
    alias m_index = 3

    var coords: SIMD[dtype, Self.envelope_simd_dims]
    var ogc_dims: CoordDims

    fn __init__(point: Point[dtype]) -> Self:
        """
        Construct Envelope of Point.
        """
        var coords = SIMD[dtype, Self.envelope_simd_dims]()

        @unroll
        for i in range(Self.point_simd_dims):
            coords[i] = point.coords[i]
            coords[i + Self.point_simd_dims] = point.coords[i]
        return Self { coords: coords, ogc_dims: point.ogc_dims }

    # fn __init__(line_string: LineString[simd_dims, dtype]) -> Self:
    #     """
    #     Construct Envelope of LineString.
    #     """
    #     return Self(line_string.data)

    fn __init__(data: Layout[dtype=dtype]) -> Self:
        """
        Construct Envelope from memory Layout.
        """
        alias nelts = simdbitwidth()
        alias n = Self.envelope_simd_dims
        var coords = SIMD[dtype, Self.envelope_simd_dims]()

        # fill initial values of with inf/neginf at each position in the 2*n array
        @unroll
        for d in range(n):  # dims 1:4
            coords[d] = max_finite[dtype]()  # min (southwest) values, start from max finite.

        @unroll
        for d in range(Self.point_simd_dims, n):  # dims 5:8
            coords[d] = min_finite[dtype]()  # max (northeast) values, start from min finite

        let num_features = data.coordinates.shape()[1]

        # vectorized load and min/max calculation for each of the dims
        @unroll
        for dim in range(Self.point_simd_dims):
            @parameter
            fn min_max_simd[simd_width: Int](feature_idx: Int):
                let index = Index(dim, feature_idx)
                let values = data.coordinates.simd_load[simd_width](index)
                let min = values.reduce_min()
                if min < coords[dim]:
                    coords[dim] = min
                let max = values.reduce_max()
                if max > coords[Self.point_simd_dims + dim]:
                    coords[Self.point_simd_dims + dim] = max

            vectorize[nelts, min_max_simd](num_features)

        return Self {coords: coords, ogc_dims: data.ogc_dims }


    @staticmethod
    fn empty(ogc_dims: CoordDims = CoordDims.Point) -> Self:
        let coords = SIMD[dtype, Self.envelope_simd_dims](empty_value[dtype]())
        return Self { coords: coords, ogc_dims: ogc_dims }

    fn __eq__(self, other: Self) -> Bool:
        # NaN is used as empty value, so here cannot simply compare with __eq__ on the SIMD values.
        @unroll
        for i in range(Self.envelope_simd_dims):
            if is_empty(self.coords[i]) and is_empty(other.coords[i]):
               pass  # equality at index i
            else:
                if is_empty(self.coords[i]) or is_empty(other.coords[i]):
                    return False  # early out: one or the other is empty (but not both) -> not equal
                if self.coords[i] != other.coords[i]:
                    return False  # not equal
        return True  # equal

    fn __ne__(self, other: Self) -> Bool:
        return not self == other

    fn __repr__(self) -> String:
        var res = "Envelope [" + dtype.__str__() + "]("
        for i in range(Self.envelope_simd_dims):
            res += str(self.coords[i])
            if i < Self.envelope_simd_dims - 1:
                res += ", "
        res += ")"
        return res

    #
    # Getters
    #
    fn southwesterly_point(self) -> Self.PointT:
        alias offset = 0
        return Self.PointT(self.coords.slice[Self.point_simd_dims](offset))

    fn northeasterly_point(self) -> Self.PointT:
        alias offset = Self.point_simd_dims
        return Self.PointT(self.coords.slice[Self.point_simd_dims](offset))

    @always_inline
    fn min_x(self) -> SIMD[dtype, 1]:
        let i = self.x_index
        return self.coords[i]

    @always_inline
    fn max_x(self) -> SIMD[dtype, 1]:
        let i = Self.point_simd_dims + self.x_index
        return self.coords[i]

    @always_inline
    fn min_y(self) -> SIMD[dtype, 1]:
        alias i = self.y_index
        return self.coords[i]

    @always_inline
    fn max_y(self) -> SIMD[dtype, 1]:
        alias i = Self.point_simd_dims + Self.y_index
        return self.coords[i]

    @always_inline
    fn min_z(self) -> SIMD[dtype, 1]:
        alias i = Self.z_index
        return self.coords[i]

    @always_inline
    fn max_z(self) -> SIMD[dtype, 1]:
        alias i = Self.point_simd_dims + Self.z_index
        return self.coords[i]

    @always_inline
    fn min_m(self) -> SIMD[dtype, 1]:
        let i = self.m_index
        return self.coords[i]

    @always_inline
    fn max_m(self) -> SIMD[dtype, 1]:
        let i = Self.point_simd_dims + Self.m_index
        return self.coords[i]

    fn dims(self) -> SIMD[DType.uint8, 1]:
        pass

    fn has_height(self) -> Bool:
        return (self.ogc_dims == CoordDims.PointZ) or (self.ogc_dims == CoordDims.PointZM)

    fn has_measure(self) -> Bool:
        return (self.ogc_dims == CoordDims.PointM) or (self.ogc_dims == CoordDims.PointZM)

    fn is_empty(self) -> Bool:
        return is_empty[dtype](self.coords)


    fn wkt(self) -> String:
        """
        TODO: wkt.
        POLYGON ((xmin ymin, xmax ymin, xmax ymax, xmin ymax, xmin ymin)).
        """
        return "POLYGON ((xmin ymin, xmax ymin, xmax ymax, xmin ymax, xmin ymin))"