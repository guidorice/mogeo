from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from memory import memcmp

from geo_features.serialization import WKTParser, JSONParser
from geo_features.geom.layout import Layout
from geo_features.geom.empty import is_empty, empty_value
from geo_features.geom.traits import Geometric, Emptyable
from geo_features.geom.point import Point
from geo_features.geom.enums import CoordDims
from geo_features.serialization import (
    WKTParser,
    WKTable,
    JSONParser,
    JSONable,
    Geoarrowable,
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
        Create empty MultiPoint.
        """
        self.data = Layout[dtype]()

    fn __init(inout self, data: Layout[dtype]):
        self.data = data

    fn __init__(inout self, *points: Point[dtype]):
        """
        Create MultiPoint from a variadic (var args) list of Points.
        """
        let n = len(points)
        let dims = len(points[0])
        self.data = Layout[dtype](coords_size=n)
        for y in range(dims):
            for x in range(n):
                self.data.coordinates[Index(y, x)] = points[x].coords[y]

    fn __init__(inout self, points: DynamicVector[Point[dtype]]):
        """
        Create MultiPoint from a vector of Points.
        """
        let n = len(points)
        if len(points) == 0:
            # create empty Multipoint
            self.data = Layout[dtype]()
            return
        let sample_pt = points[0]
        let dims = len(sample_pt)
        self.data = Layout[dtype](coords_size=n)
        for y in range(dims):
            for x in range(n):
                let value = points[x].coords[y]
                self.data.coordinates[Index(y, x)] = value

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        # TODO: impl from_json
        raise Error("not implemented")

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        # TODO: impl from_json
        raise Error("not implemented")

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        let geometry_sequence = WKTParser.parse(wkt)
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
        """
        Create Point from geoarrow / pyarrow table with geometry column.
        """
        raise Error("not implemented")

    @staticmethod
    fn empty(ogc_dims: CoordDims = CoordDims.Point) -> Self:
        return Self()

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

    fn __getitem__(self: Self, feature_index: Int) -> Point[dtype]:
        """
        Get Point from MultiPoint at index.
        """
        var point = Point[dtype]()
        for dim_index in range(self.dims()):
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
        return self.__repr__()

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
        var res = String("MULTIPOINT (")
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

    fn geoarrow(self) -> PythonObject:
        # TODO: geoarrow
        return PythonObject()
