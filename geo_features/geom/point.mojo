from python import Python
from math import nan, isnan
from math.limit import max_finite

from geo_features.serialization import WKTParser, JSONParser

alias Point2 = Point[dims=2, dtype=DType.float64]
"""
Alias for 2D point with dtype float64.
"""

alias Point3 = Point[dims=4, dtype=DType.float64]
"""
Alias for 3D point with dtype float64. Note: dims is 4 because is backed by SIMD length 4 (power of two constraint).
"""

alias Point4 = Point[dims=4, dtype=DType.float64]
"""
Alias for 4D point with dtype float64.
"""


@value
@register_passable("trivial")
struct Point[dims: Int = 2, dtype: DType = DType.float64]:
    """
    Point is a register-passable, copy-efficient struct holding 2 or more dimension values.
    """

    var coords: SIMD[dtype, dims]

    fn __init__() -> Self:
        """
        Create Point with empty values (NaN for float or max finite for integers).
        """
        @parameter
        constrained[dims % 2 == 0, "dims must be power of two"]()

        @parameter
        if dtype.is_floating_point():
            let coords = SIMD[dtype, dims](nan[dtype]())
            return Self{ coords: coords }
        else:
            let coords = SIMD[dtype, dims](max_finite[dtype]())
            return Self{ coords: coords }


    fn __init__(*coords_list: SIMD[dtype, 1]) -> Self:
        """
        Create Point from variadic list of SIMD vectors size 1. Any missing elements are padded with zeros.

        ### Example

        ```mojo
        _ = Point2(-108.680, 38.974)  # x, y or lon, lat
        _ = Point3(-108.680, 38.974, 8.0)  # x, y, z or lon, lat, height
        _ = Point4(-108.680, 38.974, 8.0, 42.0)  # x, y, z (height), m (measure).
        ```
        """
        @parameter
        constrained[dims % 2 == 0, "dims must be power of two"]()

        var result = Self()
        for i in range(len(coords_list)):
            if i >= dims:
                break
            result.coords[i] = coords_list[i]
        return result

    fn __init__(coords: SIMD[dtype, dims]) -> Self:
        """
        Create Point from existing SIMD vector of coordinates. Warning: does not initialize unused dims with empty values.

        ### Example

        ```mojo
        _ = Point[dtype, dims]{ coords: coords }
        ```
        """
        @parameter
        constrained[dims % 2 == 0, "dims must be power of two"]()
 
        return Self {coords: coords}

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """
        Create Point from geojson (expect to have been parsed into a python dict).

        ### Example

        ```mojo
        let json = Python.import_module("json")
        let point_dict = json.loads('{"type": "Point","coordinates": [102.0, 3.5]}')
        _ = Point2.from_json(point_dict)
        ```
        """
        let json_coords = json_dict["coordinates"]
        let coords_len = json_coords.__len__().to_float64().to_int()  # FIXME: to_int workaround
        var result = Self()
        debug_assert(
            dims >= coords_len, "from_json() invalid dims vs. json coordinates"
        )
        for i in range(coords_len):
            result.coords[i] = json_coords[i].to_float64().cast[dtype]()
        return result

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        """
        Create Point from geojson string.

        ### Example

        ```mojo
        let json_str = String('{"type": "Point","coordinates": [102.0, 3.5]}')
        _ = Point2.from_json(json_str)
        ```
        """
        let json_dict = JSONParser.parse(json_str)
        return Self.from_json(json_dict)

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        """
        Create Point from WKT string.

        ### Example

        ```mojo
        _ = Point2.from_wkt("POINT(-108.680 38.974)")
        ```
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
        # FIXME: a POINT M has memory layout identical to a POINT Z, ex: `30.0, 10.0, 40.0, nan`

        let ga = Python.import_module("geoarrow.pyarrow")
        let geoarrow = ga.as_geoarrow(table["geometry"])
        let chunk = geoarrow[0]
        let n = chunk.value.__len__()
        if n > dims:
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
        let coords = SIMD[dtype, dims](0)
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
        Get the z or altitude value (2 index). Returns NaN if there is no z coordinate in `dims`.
        """
        @parameter
        constrained[dims >= 3, "Point dims has no Z value"]()

        return self.coords[2]

    fn alt(self) -> SIMD[dtype, 1]:
        """
        Get the z or altitude value (2 index). Returns NaN if there is no z coordinate in `dims`.
        """
        return self.z()

    fn m(self) -> SIMD[dtype, 1]:
        """
        Get the measure value (3 index). Returns NaN if there is no m coordinate in `dims`.
        """
        @parameter
        constrained[dims >= 4, "Point dims has no M value"]()

        return self.coords[3] if dims >= 4 else 0

    fn has_height(self) -> Bool:
        """
        Check if there is a height (z) value.
        """
        @parameter
        if dims < 3:
            return False

        @parameter
        if dtype.is_floating_point():
            return isnan(self.coords[2])
        else:
            return self.coords[2] == max_finite[dtype]()
    
    fn has_measure(self) -> Bool:
        """
        Check if there is a measure (m) value.
        """
        @parameter
        if dims < 4:
            return False

        @parameter
        if dtype.is_floating_point():
            return isnan(self.coords[3])
        else:
            return self.coords[3] == max_finite[dtype]()

    fn __getitem__(self, d: Int) -> SIMD[dtype, 1]:
        """
        Get the value of coordinate at this dimension.
        """
        return self.coords[d] if d < dims else 0

    fn __eq__(self, other: Self) -> Bool:
        return Bool(self.coords == other.coords)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        var res = "Point[" + String(dims) + ", " + dtype.__str__() + "]("
        for i in range(dims):
            res += self.coords[i]
            if i < dims - 1:
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
            if i > dims - 1:
                break
            res += self.coords[i]
            if i < 2 and i < dims - 1:
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
        for i in range(dims):
            res += self.coords[i]
            if i < dims - 1:
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
