from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp

from geo_features.serialization import WKTParser, JSONParser
from .point import Point
from .layout import Layout
from ._utils import is_empty, empty_value


alias MultiPoint2 = MultiPoint[simd_dims=2, dtype = DType.float64]
"""
Alias for 2D MultiPoint with dtype float64.
"""

alias MultiPointZ = MultiPoint[simd_dims=4, dtype = DType.float64]
"""
Alias for 3D MultiPoint with dtype float64, including Z (height) dimension.
Note: dims is 4 because of SIMD memory model length 4 (power of two constraint).
"""

alias MultiPointM = MultiPoint[simd_dims=4, dtype = DType.float64]
"""
Alias for 3D MultiPoint with dtype float64, including M (measure) dimension.
Note: dims is 4 because of SIMD memory model length 4 (power of two constraint).
"""

alias MultiPointZM = MultiPoint[simd_dims=4, dtype = DType.float64]
"""
Alias for 4D MultiPoint with dtype float64, including Z (height) and M (measure) dimension.
"""


struct MultiPoint[simd_dims: Int, dtype: DType](Sized, Stringable):
    """
    Models an OGC-style MultiPoint. Any collection of Points is a valid MultiPoint,
    except [heterogeneous dimension multipoints](https://geoarrow.org/format) which are unsupported.
    """

    var data: Layout[coord_dtype=dtype]

    fn __init__(inout self):
        """
        Create empty MultiPoint.
        """
        self.data = Layout[coord_dtype=dtype]()

    fn __init__(inout self, *points: Point[simd_dims, dtype]):
        """
        Create MultiPoint from a variadic (var args) list of Points.
        """
        let n = len(points)
        var v = DynamicVector[Point[simd_dims, dtype]](n)
        for i in range(n):
            v.push_back(points[i])
        self.__init__(v)

    fn __init__(inout self, points: DynamicVector[Point[simd_dims, dtype]]):
        """
        Create MultiPoint from a vector of Points.
        """
        let n = len(points)
        if len(points) == 0:
            # create empty Multipoint
            self.data = Layout[coord_dtype=dtype]()
            return

        let sample_pt = points[0]
        let dims = len(sample_pt)
        self.data = Layout[dtype](
            dims=dims, coords_size=n, geoms_size=0, parts_size=0, rings_size=0
        )
        for y in range(dims):
            for x in range(len(points)):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    fn __copyinit__(inout self, other: Self):
        self.data = other.data

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """ """
        # TODO: impl from_json
        raise Error("not implemented")

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        """ """
        # TODO: impl from_wkt
        raise Error("not implemented")

    fn __len__(self) -> Int:
        """
        Returns the number of point elements.
        """
        return self.data.coordinates.shape()[1]

    fn __eq__(self, other: Self) -> Bool:
        return self.data == other.data

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        let dims = self.data.dims()
        return (
            "MultiPoint["
            + String(dims)
            + ", "
            + str(dtype)
            + "]("
            + String(len(self))
            + " points)"
        )

    fn __getitem__(self: Self, feature_index: Int) -> Point[simd_dims, dtype]:
        """
        Get Point from MultiPoint at index.
        """
        let dims = self.data.dims()
        var point = Point[simd_dims, dtype]()

        for dim_index in range(dims):
            point.coords[dim_index] = self.data.coordinates[
                Index(dim_index, feature_index)
            ]

        # TODO: handle 3 dim cases

        # @parameter
        # if point_simd_dims >= 4:
        #     if dims == 3:
        #         # Handle case where because of memory model, cannot distinguish a PointZ from a PointM.
        #         # Just copy the value between dim 3 and 4.
        #         point.coords[3] = point[2]

        return point

    fn __str__(self) -> String:
        return self.wkt()

    fn json(self) -> String:
        """
        GeoJSON representation of MultiPoint. Coordinates of MultiPoint are an array of positions.

        ### Spec

        - https://geojson.org
        - https://datatracker.ietf.org/doc/html/rfc7946

        ```json
        {
             "type": "MultiPoint",
             "coordinates": [
                 [100.0, 0.0],
                 [101.0, 1.0]
             ]
         }
         ```
        """
        let n = len(self)
        let dims = self.data.dims()
        var res = String('{"type":"MultiPoint","coordinates":[')
        for feature_index in range(n):
            let pt = self[feature_index]
            res += "["
            for dim_index in range(3):
                if dim_index > dims - 1:
                    break
                res += pt[dim_index]
                if dim_index < 2 and dim_index < dims - 1:
                    res += ","
            res += "]"
            if feature_index < n - 1:
                res += ","
        res += "]}"
        return res

    fn wkt(self) -> String:
        """
        Well Known Text (WKT) representation of MultiPoint.

        ### Spec

        https://libgeos.org/specifications/wkt
        """
        if self.is_empty():
            return "MULTIPOINT EMPTY"
        let dims = self.data.dims()
        var res = String("MULTIPOINT(")
        let n = len(self)
        for i in range(n):
            let pt = self[i]
            for j in range(dims):
                res += pt.coords[j]
                if j < dims - 1:
                    res += " "
            if i < n - 1:
                res += ", "
        res += ")"
        return res

    fn is_empty(self) -> Bool:
        return len(self) == 0
