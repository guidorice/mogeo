from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp

from geo_features.inter import WKTParser, JSONParser
from .point import Point

alias LineString2 = LineString[DType.float32, 2]
alias LineString3 = LineString[DType.float32, 3]
alias LineString4 = LineString[DType.float32, 4]

alias LinearRing2 = LineString[DType.float32, 2]
alias LinearRing3 = LineString[DType.float32, 3]
alias LinearRing4 = LineString[DType.float32, 4]


struct LineString[dtype: DType, point_dims: Int]:
    """
    Models an OGC-style LineString

    A LineString consists of a sequence of two or more vertices along with all points along the linearly-interpolated
    curves (line segments) between each pair of consecutive vertices. Consecutive vertices may be equal.

    The line segments in the line may intersect each other (in other words, the linestring may "curl back" in itself and
    self-intersect).

    - Linestrings with exactly two identical points are invalid.
    - Linestrings must have either 0 or 2 or more points.
    - If these conditions are not met, the constructors raise an Error.

    Coordinates of are composed of a Tensor of positions:

    ```
    x1,y1
    x2,y2
    ...
    xn,yn
    ```

    ### Example

    ```
    _ = LineString2(Point2(-108.680, 38.974), Point2(-108.680, 38.974))

    var points_vec = DynamicVector[Point2](10)

    for n in range(0, 10):
        points_vec.push_back( Point2(lon + n, lat - n) )
    _ = LineString2(points_vec)
    ```

    """

    var coords: Tensor[dtype]

    fn __init__(inout self, *points: Point[dtype, point_dims]) raises:
        """
        Create LineString from a variadic (var args) list of Points.

         ### Raises Error

        - Linestrings with exactly two identical points are invalid.
        - Linestrings must have either 0 or 2 or more points.
        """
        let args = VariadicList(points)

        let height = len(args)
        let width = point_dims
        let spec = TensorSpec(dtype, height, width)
        self.coords = Tensor[dtype](spec)
        for y in range(0, height):
            for x in range(0, width):
                self.coords[Index(y, x)] = args[y].coords[x]
        self.validate()

    fn __init__(inout self, points: DynamicVector[Point[dtype, point_dims]]) raises:
        """
        Create LineString from a vector of Points.

        ### Raises Error

        - Linestrings with exactly two identical points are invalid.
        - Linestrings must have either 0 or 2 or more points.
        """
        let height = len(points)
        let width = point_dims
        let spec = TensorSpec(dtype, height, width)
        self.coords = Tensor[dtype](spec)
        for y in range(0, height):
            for x in range(0, width):
                self.coords[Index(y, x)] = points[y].coords[x]
        self.validate()

    fn validate(self) raises:
        let len = self.__len__()
        if len == 2 and self[0] == self[1]:
            raise Error("LineStrings with exactly two identical points are invalid.")
        if self.__len__() == 1:
            raise Error("LineStrings must have either 0 or 2 or more points.")
        if self.is_closed():
            raise Error("LineStrings must not be closed: see LinearRing.")

    fn __copyinit__(inout self, other: Self):
        self.coords = other.coords

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
        return self.coords.shape()[0]

    fn __eq__(self, other: Self) -> Bool:
        """
        Equality check by direct memory comparison of 2 tensors buffers.
        """
        let n = self.coords.num_elements()
        if n != other.coords.num_elements():
            return False
        let self_buffer = self.coords.data()
        let other_buffer = other.coords.data()
        return memcmp[dtype](self_buffer, other_buffer, n) == 0

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return (
            "LineString["
            + dtype.__str__()
            + ", "
            + String(point_dims)
            + "]("
            + String(self.__len__())
            + " points)"
        )

    @always_inline
    fn __getitem__(self: Self, index: Int) -> Point[dtype, point_dims]:
        """
        Get Point from LineString at index.
        """
        let x = self.coords[Index(index, 0)]
        let y = self.coords[Index(index, 1)]
        return Point[dtype, point_dims](x, y)

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
        for i in range(0, len):
            let pt = self[i]
            res += "["
            for j in range(0, 3):
                if j > point_dims - 1:
                    break
                res += self.coords[j]
                if j < 2 and j < point_dims - 1:
                    res += ","
            res += "]"
            if i < len - 1:
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
        for i in range(0, len):
            let pt = self[i]
            for j in range(0, point_dims):
                res += pt.coords[j]
                if j < point_dims - 1:
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

        let x1 = self.coords[Index(0, 0)]
        let y1 = self.coords[Index(0, 1)]
        let start_pt = Point[dtype, point_dims](x1, y1)

        let x2 = self.coords[Index(len - 1, 0)]
        let y2 = self.coords[Index(len - 1, 1)]
        let end_pt = Point[dtype, point_dims](x2, y2)

        return start_pt == end_pt

    fn is_ring(self) -> Bool:
        # TODO: implement is_simple() after traits land: will be easier to implement operators then (see JTS)
        # return self.is_closed() and self.is_simple()
        return self.is_closed()

    fn is_simple(self) raises -> Bool:
        """
        A geometry is simple if it has no points of self-tangency, self-intersection or other anomalous points.
        """
        # TODO: implement is_simple() after mojo traits land: will be easier to implement operators then (see JTS)
        raise Error("not implemented")

    fn is_empty(self) -> Bool:
        return self.__len__() == 0
