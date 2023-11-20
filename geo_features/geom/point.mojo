from python import Python
from math import nan, isnan
from math.limit import max_finite

from geo_features.serialization import WKTParser, JSONParser

alias Point2 = Point[simd_dims=2, dtype=DType.float64]
"""
Alias for 2D point with dtype float64.
"""

alias PointZ = Point[simd_dims=4, dtype=DType.float64]
"""
Alias for 3D point with dtype float64, including Z (height) dimension.
Note: dims is 4 because of SIMD memory model length 4 (power of two constraint).
"""

alias PointM = Point[simd_dims=4, dtype=DType.float64]
"""
Alias for 3D point with dtype float64, including M (measure) dimension.
Note: dims is 4 because of SIMD memory model length 4 (power of two constraint).
"""

alias PointZM = Point[simd_dims=4, dtype=DType.float64]
"""
Alias for 4D point with dtype float64, including Z (height) and M (measure) dimension.
"""

# struct PointEnum:
#  TODO is this PointEnum even needed?
#     """
#     Enum for expressing the variants of Points as either parameter values or runtime args.
#     """
#     var value: SIMD[DType.uint8, 1]

#     alias Point = PointEnum(0)
#     """
#     2 dimensional Point.
#     """
#     alias PointZ = PointEnum(1)  
#     """
#     3 dimensional Point, has height or altitude (Z).
#     """
#     alias PointM = PointEnum(2)
#     """
#     3 dimensional Point, has measure (M).
#     """
#     alias PointZM = PointEnum(3)
#     """
#     4 dimensional Point, has height and measure  (ZM)
#     """


@value
@register_passable("trivial")
struct Point[simd_dims: Int = 2, dtype: DType = DType.float64]:
    """
    Point is a register-passable, copy-efficient struct holding 2 or more dimension values.
    """

    var coords: SIMD[dtype, simd_dims]

    fn __init__() -> Self:
        """
        Create Point with empty values (NaN for float or max finite for integers).
        """
        @parameter
        constrained[simd_dims % 2 == 0, "dims must be power of two"]()

        @parameter
        if dtype.is_floating_point():
            let coords = SIMD[dtype, simd_dims](nan[dtype]())
            return Self{ coords: coords }
        else:
            let coords = SIMD[dtype, simd_dims](max_finite[dtype]())
            return Self{ coords: coords }


    fn __init__(*coords_list: SIMD[dtype, 1]) -> Self:
        """
        Create Point from variadic list of SIMD values. Any missing elements are padded with zeros.
        Warning: it is not possible to distinguish a PointZ from a PointM in this implementation with SIMD dim 4.
        """
        @parameter
        constrained[simd_dims % 2 == 0, "dims must be power of two"]()

        var result = Self()
        let n = len(coords_list)
        for i in range(n):
            if i >= simd_dims:
                break
            result.coords[i] = coords_list[i]

        @parameter
        if simd_dims >= 4:
            if n == 3:
                # Handle case where because of memory model, cannot distinguish a PointZ from a PointM.
                # Just copy the value between dim 3 and 4.
                result.coords[3] = coords_list[2]

        return result

    fn __init__(coords: SIMD[dtype, simd_dims]) -> Self:
        """
        Create Point from existing SIMD vector of coordinates.
        Warning: does not initialize unused dims with NaN values.
        """
        @parameter
        constrained[simd_dims % 2 == 0, "dims must be power of two"]()
 
        return Self {coords: coords}

    fn has_height(self) -> Bool:
        alias z_idx = 2
        @parameter
        if dtype.is_floating_point():
            return not isnan(self.coords[z_idx])
        else:
            return self.coords[z_idx] != max_finite[dtype]()


    fn has_measure(self) -> Bool:
        alias m_idx = 3
        @parameter
        if dtype.is_floating_point():
            return not isnan(self.coords[m_idx])
        else:
            return self.coords[m_idx] != max_finite[dtype]()

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """
        Create Point from geojson (expect to have been parsed into a python dict).
        """
        let json_coords = json_dict["coordinates"]
        let coords_len = json_coords.__len__().to_float64().to_int()  # FIXME: to_int workaround
        var result = Self()
        debug_assert(
            simd_dims >= coords_len, "from_json() invalid dims vs. json coordinates"
        )
        for i in range(coords_len):
            result.coords[i] = json_coords[i].to_float64().cast[dtype]()
        return result

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        """
        Create Point from geojson string.
        """
        let json_dict = JSONParser.parse(json_str)
        return Self.from_json(json_dict)

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        """
        Create Point from WKT string.
        """
        var result = Self()
        let geos_pt = WKTParser.parse(wkt)
        let coords_tuple = geos_pt.coords[0]
        let coords_len = coords_tuple.__len__().to_float64().to_int()
        for i in range(coords_len):
            result.coords[i] = coords_tuple[i].to_float64().cast[dtype]()
        return result

    @staticmethod
    fn from_geoarrow(table: PythonObject) raises -> Self:
        """
        Create Point from geoarrow / pyarrow table with geometry column.
        """
        let ga = Python.import_module("geoarrow.pyarrow")
        let geoarrow = ga.as_geoarrow(table["geometry"])
        let chunk = geoarrow[0]
        let n = chunk.value.__len__()
        if n > simd_dims:
            raise Error("Invalid Point dims parameter vs. geoarrow: " + n.to_string())
        var result = Self()
        for dim in range(n):
            let val = chunk.value[dim].as_py().to_float64().cast[dtype]()
            result.coords[dim] = val
        return result

    @staticmethod
    fn zero() -> Self:
        """
        Null Island is an imaginary place located at zero degrees latitude and zero degrees longitude (0°N 0°E)
        https://en.wikipedia.org/wiki/Null_Island .

        ### See also

        empty() and is_empty()- the zero point is not the same as empty point.
        """
        let coords = SIMD[dtype, simd_dims](0)
        return Self { coords: coords }

    @always_inline
    fn x(self) -> SIMD[dtype, 1]:
        """
        Get the x value (0 index).
        """
        return self.coords[0]

    @always_inline
    fn y(self) -> SIMD[dtype, 1]:
        """
        Get the y value (1 index).
        """
        return self.coords[1]

    fn z(self) -> SIMD[dtype, 1]:
        """
        Get the z or altitude value (2 index).
        """
        @parameter
        constrained[simd_dims >= 3, "Point has no Z dimension"]()

        return self.coords[2]

    fn alt(self) -> SIMD[dtype, 1]:
        """
        Get the z or altitude value (2 index).
        """
        return self.z()

    fn m(self) -> SIMD[dtype, 1]:
        """
        Get the measure value (3 index).
        """
        @parameter
        constrained[simd_dims >= 3, "Point has no M dimension"]()
        return self.coords[3]

    fn __getitem__(self, d: Int) -> SIMD[dtype, 1]:
        """
        Get the value of coordinate at this dimension.
        """
        return self.coords[d] if d < simd_dims else 0

    fn __eq__(self, other: Self) -> Bool:
        return Bool(self.coords == other.coords)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        var res = "Point[" + String(simd_dims) + ", " + dtype.__str__() + "]("
        for i in range(simd_dims):
            res += self.coords[i]
            if i < simd_dims - 1:
                res += ", "
        res += ")"
        return res

    fn __str__(self) -> String:
        return self.wkt()

    fn json(self) -> String:
        """
        GeoJSON representation of Point. Point coordinates are in x, y order (easting, northing for projected
        coordinates, longitude, and latitude for geographic coordinates).

        ### Spec

        - https://geojson.org
        - https://datatracker.ietf.org/doc/html/rfc7946
        """
        # include only x, y, and optionally z (altitude)
        var res = String('{"type":"Point","coordinates":[')
        for i in range(3):
            if i > simd_dims - 1:
                break
            res += self.coords[i]
            if i < 2 and i < simd_dims - 1:
                res += ","
        res += "]}"
        return res

    fn wkt(self) -> String:
        """
        Well Known Text (WKT) representation of Point.

        ### Spec

        https://libgeos.org/specifications/wkt
        """
        if self.is_empty():
            return "POINT EMPTY"

        var res = String("POINT(")
        for i in range(simd_dims):
            res += self.coords[i]
            if i < simd_dims - 1:
                res += " "
        res += ")"
        return res

    fn is_empty(self) -> Bool:
        @parameter
        if dtype.is_floating_point():
            return isnan(self.coords)
        else:
            let all_nan = max_finite[dtype]()
            return self.coords == all_nan
