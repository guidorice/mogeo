from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp
from python import Python

from mogeo.serialization import WKTParser, JSONParser
from mogeo.geom.layout import Layout
from mogeo.geom.empty import is_empty, empty_value
from mogeo.geom.traits import Geometric, Emptyable
from mogeo.geom.point import Point
from mogeo.geom.enums import CoordDims
from mogeo.serialization.traits import WKTable, JSONable, Geoarrowable
from mogeo.serialization import (
    WKTParser,
    JSONParser,
)


@value
struct MultiPoint[dtype: DType = DType.float64](
    CollectionElement,
    Emptyable,
    Geoarrowable,
    Geometric,
    JSONable,
    Sized,
    Stringable,
    WKTable,
):
    """
    Models an OGC-style MultiPoint. Any collection of Points is a valid MultiPoint,
    except [heterogeneous dimension multipoints](https://geoarrow.org/format) which are unsupported.
    """

    var data: Layout[dtype]

    fn __init__(inout self):
        """
        Construct empty MultiPoint.
        """
        self.data = Layout[dtype]()

    fn __init(inout self, data: Layout[dtype]):
        self.data = data

    fn __init__(inout self, *points: Point[dtype]):
        """
        Construct `MultiPoint` from a variadic list of `Points`.
        """
        debug_assert(len(points) > 0, "unreachable")
        let n = len(points)
        # sample 1st point as prototype to get dims
        let sample_pt = points[0]
        let dims = len(sample_pt)
        self.data = Layout[dtype](ogc_dims=sample_pt.ogc_dims, coords_size=n)
        for y in range(dims):
            for x in range(n):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    fn __init__(inout self, points: DynamicVector[Point[dtype]]):
        """
        Construct `MultiPoint` from a vector of `Point`.
        """
        let n = len(points)
        if len(points) == 0:
            # early out with empty MultiPoint
            self.data = Layout[dtype]()
            return
        # sample 1st point as prototype to get dims
        let sample_pt = points[0]
        let dims = len(sample_pt)
        self.data = Layout[dtype](ogc_dims=sample_pt.ogc_dims, coords_size=n)
        for dim in range(dims):
            for i in range(n):
                let value = points[i].coords[dim]
                self.data.coordinates[Index(dim, i)] = value

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """
        Construct `MultiPoint` from GeoJSON (Python dictionary).
        """
        let json_coords = json_dict["coordinates"]
        let n = int(json_coords.__len__())
        # TODO: type checking of json_dict (coordinates property exists)
        let dims = json_coords[0].__len__().to_float64().to_int()
        let ogc_dims = CoordDims.PointZ if dims == 3 else CoordDims.Point
        var data = Layout[dtype](ogc_dims, coords_size=n)
        for dim in range(dims):
            for i in range(n):
                let point = json_coords[i]
                # TODO: bounds check of geojson point
                let value = point[dim].to_float64().cast[dtype]()
                data.coordinates[Index(dim, i)] = value
        return Self(data)

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        """
        Construct `MultiPoint` from GeoJSON serialized string.
        """
        let json_dict = JSONParser.parse(json_str)
        return Self.from_json(json_dict)

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        let geometry_sequence = WKTParser.parse(wkt)
        # TODO: validate PythonObject is a class MultiPoint  https://shapely.readthedocs.io/en/stable/reference/shapely.MultiPoint.html
        let n = geometry_sequence.geoms.__len__().to_float64().to_int()
        if n == 0:
            return Self()
        let sample_pt = geometry_sequence.geoms[0]
        let coords_tuple = sample_pt.coords[0]
        let dims = coords_tuple.__len__().to_float64().to_int()
        let ogc_dims = CoordDims.PointZ if dims == 3 else CoordDims.Point
        var data = Layout[dtype](ogc_dims, coords_size=n)
        for y in range(dims):
            for x in range(n):
                let geom = geometry_sequence.geoms[x]
                let coords_tuple = geom.coords[0]
                let value = coords_tuple[y].to_float64().cast[dtype]()
                data.coordinates[Index(y, x)] = value
        return Self(data)

    @staticmethod
    fn from_geoarrow(table: PythonObject) raises -> Self:
        let ga = Python.import_module("geoarrow.pyarrow")
        let geoarrow = ga.as_geoarrow(table["geometry"])
        let chunk = geoarrow[0]
        let n = chunk.value.__len__()
        # TODO: inspect first point to see number of dims (same as in from_wkt above)
        if n > 2:
            raise Error("Invalid Point dims parameter vs. geoarrow: " + str(n))
        # TODO: add to Layout
        # return result
        return Self()

    @staticmethod
    fn empty(ogc_dims: CoordDims = CoordDims.Point) -> Self:
        return Self()

    fn __len__(self) -> Int:
        """
        Returns the number of Point elements.
        """
        return self.data.coordinates.shape()[1]

    fn __eq__(self, other: Self) -> Bool:
        return self.data == other.data

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return (
            "MultiPoint ["
            + str(self.data.ogc_dims)
            + ", "
            + str(dtype)
            + "]("
            + String(len(self))
            + " points)"
        )

    fn dims(self) -> Int:
        return len(self.data.ogc_dims)

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

    fn __getitem__(self: Self, feature_index: Int) -> Point[dtype]:
        """
        Get Point from MultiPoint at index.
        """
        var point = Point[dtype](self.data.ogc_dims)
        for dim_index in range(self.dims()):
            point.coords[dim_index] = self.data.coordinates[
                Index(dim_index, feature_index)
            ]
        return point

    fn __str__(self) -> String:
        return self.__repr__()

    fn json(self) raises -> String:
        """
        Serialize `MultiPoint` to GeoJSON. Coordinates of MultiPoint are an array of positions.

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
        if self.data.ogc_dims.value > CoordDims.PointZ.value:
            raise Error(
                "GeoJSON only allows dimensions X, Y, and optionally Z (RFC 7946)"
            )

        let n = len(self)
        let dims = self.data.dims()
        var res = String('{"type":"MultiPoint","coordinates":[')
        for i in range(n):
            let pt = self[i]
            res += "["
            for dim in range(dims):
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
            return "MULTIPOINT EMPTY"
        let dims = self.data.dims()
        var res = String("MULTIPOINT (")
        let n = len(self)
        for i in range(n):
            let pt = self[i]
            for dim in range(dims):
                res += pt[dims]
                if dim < dims - 1:
                    res += " "
            if i < n - 1:
                res += ", "
        res += ")"
        return res

    fn is_empty(self) -> Bool:
        return len(self) == 0

    fn geoarrow(self) -> PythonObject:
        # TODO: geoarrow
        return PythonObject()
