from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp

from geo_features.serialization import WKTParser, JSONParser
from .point import Point
from .layout import Layout


alias MultiPoint2 = MultiPoint[2, DType.float64]
alias MultiPoint3 = MultiPoint[3, DType.float64]
alias MultiPoint4 = MultiPoint[4, DType.float64]


struct MultiPoint[dims: Int = 2, dtype: DType = DType.float64]:
    """
    Models an OGC-style MultiPoint. Any collection of Points is a valid MultiPoint.

    Note: we do not support [heterogeneous dimension multipoints](https://geoarrow.org/format). If there is a
    concievable use case where one would want a collection of say 2d, 3d, and 4d points in a single collection,
    we could support heterogeneous points via the geoarrow.geometry_offsets struct.

    """

    var memory_layout: Layout[dims, dtype]

    fn __init__(inout self, *points: Point[dims, dtype]):
        """
        Create MultiPoint from a variadic (var args) list of Points.
        """
        let n = len(points)
        var v = DynamicVector[Point[dims, dtype]](n)
        for i in range(0, n):
            v.push_back(points[i])
        self.__init__(v)

    fn __init__(inout self, points: DynamicVector[Point[dims, dtype]]):
        """
        Create MultiPoint from a vector of Points.
        """
        let n = len(points)

        self.memory_layout = Layout[dims, dtype](
            coords_size=n, geoms_size=0, parts_size=0, rings_size=0
        )
        for y in range(0, dims):
            for x in range(0, len(points)):
                self.memory_layout.coordinates[Index(y, x)] = points[x].coords[y]

    fn __copyinit__(inout self, other: Self):
        self.memory_layout = other.memory_layout

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

    @always_inline
    fn __len__(self) -> Int:
        return self.memory_layout.coordinates.shape()[1]

    fn __eq__(self, other: Self) -> Bool:
        return self.memory_layout == other.memory_layout

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return (
            "MultiPoint["
            + String(dims)
            + ", "
            + dtype.__str__()
            + "]("
            + String(self.__len__())
            + " points)"
        )

    @always_inline
    fn __getitem__(self: Self, feature_index: Int) -> Point[dims, dtype]:
        """
        Get Point from MultiPoint at index.
        """
        var data: SIMD[dtype, dims] = 0

        @unroll
        for dim_index in range(0, dims):
            data[dim_index] = self.memory_layout.coordinates[
                Index(dim_index, feature_index)
            ]

        return Point[dims, dtype](data)

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
        var res = String('{"type":"MultiPoint","coordinates":[')
        let len = self.__len__()
        for feature_index in range(0, len):
            let pt = self[feature_index]
            res += "["
            for dim_index in range(0, 3):
                if dim_index > dims - 1:
                    break
                res += pt[dim_index]
                if dim_index < 2 and dim_index < dims - 1:
                    res += ","
            res += "]"
            if feature_index < len - 1:
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
        var res = String("MULTIPOINT(")
        let len = self.__len__()
        for i in range(0, len):
            let pt = self[i]
            for j in range(0, dims):
                res += pt.coords[j]
                if j < dims - 1:
                    res += " "
            if i < len - 1:
                res += ", "
        res += ")"
        return res

    fn is_empty(self) -> Bool:
        return self.__len__() == 0
