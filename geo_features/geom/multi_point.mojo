from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp

from geo_features.serialization import WKTParser, JSONParser
from .point import Point
from .geo_arrow import GeoArrow


alias MultiPoint2 = MultiPoint[DType.float32, 2]
alias MultiPoint3 = MultiPoint[DType.float32, 3]
alias MultiPoint4 = MultiPoint[DType.float32, 4]


struct MultiPoint[dtype: DType, dims: Int]:
    """
    Models an OGC-style MultiPoint. Any collection of Points is a valid MultiPoint.

    ### Example

    # TODO

    """

    var data: GeoArrow[dtype, dims]

    fn __init__(inout self, *points: Point[dtype, dims]):
        """
        Create MultiPoint from a variadic (var args) list of Points.
        """
        let args = VariadicList(points)
        self.data = GeoArrow[dtype, dims](len(args))
        for y in range(0, dims):
            for x in range(0, len(args)):
                self.data.coordinates[Index(y, x)] = args[x].coords[y]

    fn __init__(inout self, points: DynamicVector[Point[dtype, dims]]):
        """
        Create MultiPoint from a vector of Points.
        """
        self.data = GeoArrow[dtype, dims](len(points))
        for y in range(0, dims):
            for x in range(0, len(points)):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    fn __copyinit__(inout self, other: Self):
        self.data = other.data

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """ """
        raise Error("not implemented")

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        """ """
        raise Error("not implemented")

    @always_inline
    fn __len__(self) -> Int:
        return self.data.coordinates.shape()[1]

    fn __eq__(self, other: Self) -> Bool:
        return self.data == other.data

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return (
            "MultiPoint["
            + dtype.__str__()
            + ", "
            + String(dims)
            + "]("
            + String(self.__len__())
            + " points)"
        )

    @always_inline
    fn __getitem__(self: Self, feature_index: Int) -> Point[dtype, dims]:
        """
        Get Point from MultiPoint at index.
        """
        var data: SIMD[dtype, dims] = 0

        @unroll
        for dim_index in range(0, dims):
            data[dim_index] = self.data.coordinates[Index(dim_index, feature_index)]

        return Point[dtype, dims](data)

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
