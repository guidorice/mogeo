from python import Python
from geo_features.parser.wkt import WKTParser

alias Point2 = Point[DType.float32, 2]
"""
Alias for 2D point with dtype: float32.
"""

alias Point3 = Point[DType.float32, 4]
"""
Alias for 3D point with dtype float32. Note: is backed by SIMD vector of size 4 (power of two).
"""

alias Point4 = Point[DType.float32, 4]
"""
Alias for 2D point with dtype float32.
"""

@register_passable("trivial")
struct Point[dtype: DType, dims: Int]:
    """
    N-dimensional point. Typical dimensions: lon, lat, height, or x, y, z, m (measure).
    """
    var coords: SIMD[dtype, dims]

    fn __init__(*elems: SIMD[dtype, 1]) -> Self:
        """
        Create Point from variadic list of SIMD vectors size 1.

        ### Example

        ```
        _ = Point2(-108.680, 38.974)  # x, y or lon, lat
        _ = Point3(-108.680, 38.974, 8.0)  # x, y, z or lon, lat, height
        _ = Point4(-108.680, 38.974, 8.0, 42.0)  # x, y, z (height), m (measure).
        ```
        """
        # TODO: when argument unpacking is supported, consider removing the variadic list creation here?
        let list = VariadicList(elems)
        var coords = SIMD[dtype, dims]()
        for i in range(0, len(list)):
            coords[i] = elems[i]
        return Point[dtype, dims]{ coords: coords }

    fn __init__(owned coords: SIMD[dtype, dims]) -> Self:
        """
        Create Point from existing SIMD vector of coordinates.

        ### Example

        ```
        _ = Point[dtype, dims]{ coords: coords }
        ```
        """
        return Point[dtype, dims]{ coords: coords }

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Point[dtype, dims]:
        """
        Create Point from geojson (must be parsed into python dict).

        ### Example 

        ```
        let json = Python.import_module("json")
        let point_dict = json.loads('{"type": "Point","coordinates": [102.0, 3.5]}')
        _ = Point2.from_json(point_dict)
        ```
        """
        let json_coords = json_dict["coordinates"]
        let coords_lenn = json_coords.__len__().to_float64().to_int()  # FIXME: to_int workaround
        var coords = SIMD[dtype, dims]()
        debug_assert(dims >= coords_lenn, "from_json() invalid dims vs. json coordinates")
        for i in range(0, coords_lenn):
            coords[i] = json_coords[i].to_float64().cast[dtype]()
        return Point[dtype, dims](coords)

    @staticmethod
    def from_wkt(wkt: String) -> Point[dtype, dims]:
        """
        Create Point from WKT string.

        ### Example 

        ```
        _ = Point2.from_wkt("POINT(-108.680 38.974)")
        ```
        """
        let geos_pt = WKTParser.parse(wkt)
        var coords = SIMD[dtype, dims]()
        let coords_tuple = geos_pt.coords[0]
        let coords_len = coords_tuple.__len__().to_float64().to_int()
        debug_assert(dims >= coords_len, "from_wkt() invalid dims vs. wkt coordinates")
        for i in range(0, coords_len):  # FIXME: to_int workaround
            coords[i] =coords_tuple[i].to_float64().cast[dtype]()
        return Point[dtype, dims](coords)

    @staticmethod
    fn zero() -> Point[dtype, dims]:
        """
        Null Island is an imaginary place located at zero degrees latitude and zero degrees longitude (0°N 0°E)
        https://en.wikipedia.org/wiki/Null_Island .
        """
        return Point[dtype, dims](0, 0)

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

    fn __eq__(self, other: Self) -> Bool:
        return Bool(self.coords == other.coords)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        var res = "Point[" + dtype.__str__() + ", " + String(dims) + "]("
        for i in range(0, dims):
            res += self.coords[i]
            if i < dims -1:
                res += ", "
        res += ")"
        return res

    fn __str__(self) -> String:
        return self.wkt()

    fn json(self) -> String:
        """
        GeoJSON representation of Point.

        Point coordinates are in x, y order (easting, northing for projected
        coordinates, longitude, and latitude for geographic coordinates). Example:

        ```json
        {
            "type": "Point",
            "coordinates": [100.0, 0.0]
        }
        ```

        ### Spec

        - https://geojson.org
        - https://datatracker.ietf.org/doc/html/rfc7946
        """
        # include only x, y, and optionally z (altitude)
        var res = String('{"type":"Point","coordinates":[')
         for i in range(0, 3):
            if i > dims -1:
                break
            res += self.coords[i]
            if i < 2 and i < dims -1:
                res += ","
        res += "]}"
        return res
    
    fn wkt(self) -> String:
        """
        Well Known Text (WKT) representation of Point.

        ### Spec

        - https://libgeos.org/specifications/wkt
        """
        var res = String("POINT(")
        for i in range(0, dims):
            res += self.coords[i]
            if i < dims -1:
                res += " "
        res += ")"
        return res
