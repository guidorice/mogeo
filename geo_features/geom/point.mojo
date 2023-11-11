from math import nan, isnan
from math.limit import max_finite

from geo_features.serialization import WKTParser, JSONParser

alias Point2 = Point[2, DType.float64]
"""
Alias for 2D point with dtype: float64.
"""

alias Point3 = Point[4, DType.float64]
"""
Alias for 3D point with dtype: float64. Note this actually SIMD power of two (4).
"""

alias Point4 = Point[4, DType.float64]
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
        var coords = SIMD[dtype, dims]()

        # fill with sentinel values for is_empty()
        @parameter
        if dtype.is_floating_point():
            coords = nan[dtype]()
        else:
            coords = max_finite[dtype]()

        for i in range(len(coords_list)):
            if i >= dims:
                break
            coords[i] = coords_list[i]

        return Self {coords: coords}

    fn __init__(coords: SIMD[dtype, dims]) -> Self:
        """
        Create Point from existing SIMD vector of coordinates.

        ### Example

        ```mojo
        _ = Point[dtype, dims]{ coords: coords }
        ```
        """
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
        let coords_lenn = json_coords.__len__().to_float64().to_int()  # FIXME: was to_int workaround
        var coords = SIMD[dtype, dims]()
        debug_assert(
            dims >= coords_lenn, "from_json() invalid dims vs. json coordinates"
        )
        for i in range(coords_lenn):
            coords[i] = json_coords[i].to_float64().cast[dtype]()
        return Self(coords)

    @staticmethod
    fn from_json(json_str: String) raises -> Point[dims, dtype]:
        """
        Create Point from geojson string.

        ### Example

        ```mojo
        let json_str = String('{"type": "Point","coordinates": [102.0, 3.5]}')
        _ = Point2.from_json(json_str)
        ```
        """
        let json_dict = JSONParser.parse(json_str)
        let json_coords = json_dict["coordinates"]
        let coords_lenn = json_coords.__len__().to_float64().to_int()  # FIXME: was to_int workaround
        var coords = SIMD[dtype, dims]()
        debug_assert(
            dims >= coords_lenn, "from_json() invalid dims vs. json coordinates"
        )
        for i in range(coords_lenn):
            coords[i] = json_coords[i].to_float64().cast[dtype]()
        return Point[dims, dtype](coords)

    @staticmethod
    def from_wkt(wkt: String) -> Self:
        """
        Create Point from WKT string.

        ### Example

        ```mojo
        _ = Point2.from_wkt("POINT(-108.680 38.974)")
        ```
        """
        let geos_pt = WKTParser.parse(wkt)
        var coords = SIMD[dtype, dims]()
        let coords_tuple = geos_pt.coords[0]
        let coords_len = coords_tuple.__len__().to_float64().to_int()
        debug_assert(dims >= coords_len, "from_wkt() invalid dims vs. wkt coordinates")
        for i in range(coords_len):  # FIXME: to_int workaround
            coords[i] = coords_tuple[i].to_float64().cast[dtype]()
        return Self(coords)

    @staticmethod
    fn zero() -> Point[dims, dtype]:
        """
        Null Island is an imaginary place located at zero degrees latitude and zero degrees longitude (0°N 0°E)
        https://en.wikipedia.org/wiki/Null_Island .

        ### See also

        empty() and is_empty()- the zero point is not the same as empty point.
        """
        let coords = SIMD[dtype, dims](0)
        return Point[dims, dtype](coords)

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
        Get the z or altitude value (2 index). Returns 0 if there is no z coordinate in `dims`.
        """
        return self.coords[2] if dims >= 4 else 0

    fn alt(self) -> SIMD[dtype, 1]:
        """
        Get the z or altitude value (2 index). Returns 0 if there is no z coordinate in `dims`.
        """
        return self.z()

    fn m(self) -> SIMD[dtype, 1]:
        """
        Get the measure value (3 index). Returns 0 if there is no m coordinate in `dims`.
        """
        return self.coords[3] if dims >= 4 else 0

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
        #  TODO: EMPTY point
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
