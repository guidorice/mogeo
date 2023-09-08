from python import Python


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
        Create Point from SIMD vector.

        ### Example
        ```
        _ = Point4(SIMD[DType.float32, 4](lon, lat, height, measure))
        ```
        """
        return Point[dtype, dims]{ coords: coords }

    # @staticmethod
    # def from_json(json_dict: PythonObject) -> Point[dtype, dims]:
    #     json_coords = json_dict["coordinates"]
    #     let len = json_coords.__len__()
    #     var coords = SIMD[dtype, dims]()
    #     debug_assert(dims >= Int(len.to_int()), "from_json() invalid dims vs. json coordinates")
    #     for i in range(0, len):
    #         coords[i] = rebind[SIMD[dtype, 1]](json_coords[i].to_float64())
    #     return Point[dtype, dims](coords)

    @staticmethod
    fn zero() -> Point[dtype, dims]:
        return Point[dtype, dims](0, 0)

    fn x(self) -> SIMD[dtype, 1]:
        return self.coords[0]

    fn y(self) -> SIMD[dtype, 1]:
        return self.coords[1]

    fn z(self) -> SIMD[dtype, 1]:
        return self.coords[2] if dims >= 4 else 0

    fn m(self) -> SIMD[dtype, 1]:
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
        Returns GeoJSON representation of Point.

        Point coordinates are in x, y order (easting, northing for projected
        coordinates, longitude, and latitude for geographic coordinates):

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
        # inlcude only x, y, and optionally z (altitude)
        var res = String('{"type": "Point", "coordinates": [')
         for i in range(0, 3):
            if i > dims -1:
                break
            res += self.coords[i]
            if i < 2 and i < dims -1:
                res += ", "
        res += "]}"
        return res
    
    fn wkt(self) -> String:
        """
        Returns Well Known Text (WKT) representation of Point.

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
