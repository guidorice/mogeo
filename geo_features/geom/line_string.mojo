from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp
from python import Python

from geo_features.serialization import WKTParser, JSONParser
from .point import Point
from .layout import Layout


@value
struct LineString[dims: Int = 2, dtype: DType = DType.float64]:
    """
    Models an OGC-style LineString.

    A LineString consists of a sequence of two or more vertices along with all points along the linearly-interpolated
    curves (line segments) between each pair of consecutive vertices. Consecutive vertices may be equal.

    The line segments in the line may intersect each other (in other words, the linestring may "curl back" in itself and
    self-intersect).

    - Linestrings with exactly two identical points are invalid.
    - Linestrings must have either 0 or 2 or more points.
    - If these conditions are not met, the constructors raise an Error.
    """

    var data: Layout[dtype]

    fn __init__(inout self):
        """
        Create empty linestring.
        """
        self.data = Layout[coord_dtype=dtype](dims=dims)

    fn __init__(inout self, *points: Point[dims, dtype]):
        """
        Create LineString from a variadic (var args) list of Points.
        """
        let n = len(points)
        var v = DynamicVector[Point[dims, dtype]](n)
        for i in range(n):
            v.push_back(points[i])
        self.__init__(v)

    fn __init__(inout self, points: DynamicVector[Point[dims, dtype]]):
        """
        Create LineString from a vector of Points.
        """
        # here the geometry_offsets, part_offsets, and ring_offsets are unused because
        # of using "struct coordinate representation" (tensor)
        let n = len(points)
        self.data = Layout[coord_dtype=dtype](
            dims=dims,
            coords_size=n, geoms_size=0, parts_size=0, rings_size=0
        )
        for y in range(dims):
            for x in range(len(points)):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    fn __copyinit__(inout self, other: Self):
        self.data = other.data

    fn __len__(self) -> Int:
        return self.data.coordinates.shape()[1]

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.data == other.data

    @always_inline
    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return (
            "LineString["
            + String(dims)
            + ", "
            + dtype.__str__()
            + "]("
            + String(self.__len__())
            + " points)"
        )

    @always_inline
    fn __getitem__(self: Self, feature_index: Int) -> Point[dims=dims, dtype=dtype]:
        """
        Get Point from LineString at index.
        """
        var result = Point[dims, dtype]()
        @unroll
        for dim_index in range(dims):
            result.coords[dim_index] = self.data.coordinates[
                Index(dim_index, feature_index)
            ]
        return result

    fn is_valid(self, inout err: String) -> Bool:
        """
        Validate geometry. When False, sets the `err` string with a condition.

        - Linestrings with exactly two identical points are invalid.
        - Linestrings must have either 0 or 2 or more points.
        - LineStrings must not be closed: try LinearRing.
        """
        if self.is_empty():
            return True

        let self_len = self.__len__()
        if self_len == 2 and self[0] == self[1]:
            err = "LineStrings with exactly two identical points are invalid."
            return False
        if self_len == 1:
            err = "LineStrings must have either 0 or 2 or more points."
            return False
        if self.is_closed():
            err = "LineStrings must not be closed: try LinearRing."

        return True

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        var json_coords = json_dict.get("coordinates", Python.none())
        if not json_coords:
            raise Error("LineString.from_json(): coordinates property missing in dict.")
        var points = DynamicVector[Point[dims, dtype]]()
        for coords in json_coords:
            let lon = coords[0].to_float64().cast[dtype]()
            let lat = coords[1].to_float64().cast[dtype]()
            let pt = Point[dims, dtype](lon, lat)
            points.push_back(pt)
        return LineString[dims, dtype](points)

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        # TODO: impl from_wkt()
        # raise Error("not implemented")
        return LineString[dims, dtype]()


    fn __str__(self) -> String:
        return self.wkt()

    fn json(self) -> String:
        """
           GeoJSON representation of LineString. Coordinates of LineString are an array of positions.

           ### Spec

           - https://geojson.org
           - https://datatracker.ietf.org/doc/html/rfc7946

           {
            "type": "LineString",
            "coordinates": [
                [100.0, 0.0],
                [101.0, 1.0]
            ]
        }
        """
        var res = String('{"type":"LineString","coordinates":[')
        let len = self.__len__()
        for feature_index in range(len):
            let pt = self[feature_index]
            res += "["
            for dim_index in range(3):
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
        Well Known Text (WKT) representation of LineString.

        ### Spec

        https://libgeos.org/specifications/wkt
        """
        if self.is_empty():
            return "LINESTRING EMPTY"
        var res = String("LINESTRING(")
        let len = self.__len__()
        for i in range(len):
            let pt = self[i]
            for j in range(dims):
                res += pt.coords[j]
                if j < dims - 1:
                    res += " "
            if i < len - 1:
                res += ", "
        res += ")"
        return res

    fn is_closed(self) -> Bool:
        """
        If LineString is closed (0 and n-1 points are equal), it's not valid: a LinearRing should be used instead.
        """
        let len = self.__len__()
        if len == 1:
            return False
        let start_pt = self[0]
        let end_pt = self[len - 1]
        return start_pt == end_pt

    fn is_ring(self) -> Bool:
        # TODO: implement is_simple() after traits land: will be easier to implement operators then (see JTS)
        # return self.is_closed() and self.is_simple()
        return self.is_closed()

    fn is_simple(self) raises -> Bool:
        """
        A geometry is simple if it has no points of self-tangency, self-intersection or other anomalous points.
        """
        # TODO impl is_simple()
        raise Error("not implemented")

    fn is_empty(self) -> Bool:
        return self.__len__() == 0
