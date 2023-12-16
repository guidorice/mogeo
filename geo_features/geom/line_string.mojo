from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp
from python import Python

from geo_features.serialization import WKTParser, JSONParser
from geo_features.geom.point import Point
from geo_features.geom.layout import Layout
from geo_features.geom.enums import CoordDims
from geo_features.geom.empty import is_empty, empty_value
from geo_features.geom.traits import Geometric, Emptyable
from geo_features.serialization.traits import WKTable, JSONable, Geoarrowable
from geo_features.serialization import (
    WKTParser,
    JSONParser,
)


@value
struct LineString[dtype: DType = DType.float64](
    CollectionElement,
    Emptyable,
    # Geoarrowable,
    Geometric,
    JSONable,
    Sized,
    Stringable,
    # WKTable,
):
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
        Construct empty LineString.
        """
        self.data = Layout[dtype]()

    fn __init(inout self, data: Layout[dtype]):
        self.data = data

    fn __init__(inout self, *points: Point[dtype]):
        """
        Construct `LineString` from variadic list of `Point`.
        """
        debug_assert(len(points) > 0, "unreachable")
        let n = len(points)

        if n == 0:
            # empty linestring
            self.data = Layout[dtype]()
            return

        let sample_pt = points[0]
        let dims = len(sample_pt)
        self.data = Layout[dtype](coords_size=n)

        for y in range(dims):
            for x in range(len(points)):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    fn __init__(inout self, points: DynamicVector[Point[dtype]]):
        """
        Construct `LineString` from a vector of `Points`.
        """
        # here the geometry_offsets, part_offsets, and ring_offsets are unused because
        # of using "struct coordinate representation" (tensor)

        let n = len(points)

        if n == 0:
            # empty linestring
            self.data = Layout[dtype]()
            return

        let sample_pt = points[0]
        let dims = len(sample_pt)
        self.data = Layout[dtype](coords_size=n)

        for y in range(dims):
            for x in range(len(points)):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    @staticmethod
    fn empty(dims: CoordDims = CoordDims.Point) -> Self:
        return Self()

    fn __len__(self) -> Int:
        """
        Return the number of Point elements.
        """
        return self.data.coordinates.shape()[1]

    fn dims(self) -> Int:
        return len(self.data.ogc_dims)

    fn __eq__(self, other: Self) -> Bool:
        return self.data == other.data

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return (
            "LineString ["
            + str(self.data.ogc_dims)
            + ", "
            + dtype.__str__()
            + "]("
            + String(len(self))
            + " points)"
        )

    fn __getitem__(self: Self, feature_index: Int) -> Point[dtype]:
        """
        Get Point from LineString at index.
        """
        var result = Point[dtype]()
        for i in range(self.dims()):
            result.coords[i] = self.data.coordinates[Index(i, feature_index)]
        return result

    fn has_height(self) -> Bool:
        return self.data.has_height()

    fn has_measure(self) -> Bool:
        return self.data.has_measure()

    fn set_ogc_dims(inout self, ogc_dims: CoordDims):
        """
        Setter for ogc_dims enum. May be only be useful if the Point constructor with variadic list of coordinate values.
        (ex: when Point Z vs Point M is ambiguous.
        """
        debug_assert(
            len(self.data.ogc_dims) == len(ogc_dims),
            "Unsafe change of dimension number",
        )
        self.data.set_ogc_dims(ogc_dims)

    fn is_valid(self, inout err: String) -> Bool:
        """
        Validate geometry. When False, sets the `err` string with a condition.

        - Linestrings with exactly two identical points are invalid.
        - Linestrings must have either 0 or 2 or more points.
        - LineStrings must not be closed: try LinearRing.
        """
        if self.is_empty():
            return True

        let n = len(self)
        if n == 2 and self[0] == self[1]:
            err = "LineStrings with exactly two identical points are invalid."
            return False
        if n == 1:
            err = "LineStrings must have either 0 or 2 or more points."
            return False
        if self.is_closed():
            err = "LineStrings must not be closed: try LinearRing."

        return True

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """
        Construct `MultiPoint` from GeoJSON Python dictionary.
        """
        var json_coords = json_dict.get("coordinates", Python.none())
        if not json_coords:
            raise Error("LineString.from_json(): coordinates property missing in dict.")
        var points = DynamicVector[Point[dtype]]()
        for coords in json_coords:
            let lon = coords[0].to_float64().cast[dtype]()
            let lat = coords[1].to_float64().cast[dtype]()
            let pt = Point[dtype](lon, lat)
            points.push_back(pt)
        return LineString[dtype](points)

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        """
        Construct `LineString` from GeoJSON serialized string.
        """
        let json_dict = JSONParser.parse(json_str)
        return Self.from_json(json_dict)

    fn __str__(self) -> String:
        return self.__repr__()

    fn json(self) raises -> String:
        """
        Serialize `LineString` to GeoJSON. Coordinates of LineString are an array of positions.

        ### Spec

        - https://geojson.org
        - https://datatracker.ietf.org/doc/html/rfc7946

        ```json
           {
            "type": "LineString",
            "coordinates": [
                [100.0, 0.0],
                [101.0, 1.0]
            ]
        }
        ```
        """
        if self.data.ogc_dims.value > CoordDims.PointZ.value:
            raise Error(
                "GeoJSON only allows dimensions X, Y, and optionally Z (RFC 7946)"
            )

        let dims = self.dims()
        let n = len(self)
        var res = String('{"type":"LineString","coordinates":[')
        for i in range(n):
            let pt = self[i]
            res += "["
            for dim in range(3):
                if dim > dims - 1:
                    break
                res += pt[dim]
                if dim < dims - 1:
                    res += ","
            res += "]"
            if i < n - 1:
                res += ","
        res += "]}"
        return res

    fn wkt(self) -> String:
        if self.is_empty():
            return "LINESTRING EMPTY"
        let dims = self.dims()
        var res = String("LINESTRING(")
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

    fn is_closed(self) -> Bool:
        """
        If LineString is closed (0 and n-1 points are equal), it's not valid: a LinearRing should be used instead.
        """
        let n = len(self)
        if n == 1:
            return False
        let start_pt = self[0]
        let end_pt = self[n - 1]
        return start_pt == end_pt

    fn is_empty(self) -> Bool:
        return len(self) == 0
