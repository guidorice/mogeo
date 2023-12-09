from python import Python
from math import nan, isnan
from math.limit import max_finite

from ._utils import empty_value, is_empty

from geo_features.serialization import WKTParser, JSONParser

alias Point2 = Point[simd_dims=2, dtype=DType.float64, T=PointEnum.Point]
"""
Alias for 2D point with dtype float64.
"""

alias PointZ = Point[simd_dims=4, dtype=DType.float64, T=PointEnum.PointZ]
"""
Alias for 3D point with dtype float64, including Z (height) dimension.
Note: dims is 4 because of SIMD memory model length 4 (power of two constraint).
"""

alias PointM = Point[simd_dims=4, dtype=DType.float64, T=PointEnum.PointM]
"""
Alias for 3D point with dtype float64, including M (measure) dimension.
Note: dims is 4 because of SIMD memory model length 4 (power of two constraint).
"""

alias PointZM = Point[simd_dims=4, dtype=DType.float64, T=PointEnum.PointZM]
"""
Alias for 4D point with dtype float64, including Z (height) and M (measure) dimension.
"""

@register_passable("trivial")
struct PointEnum(Stringable):
    """
    Enum for expressing the variants of Points as either parameter values or runtime args.
    """
    var value: SIMD[DType.uint8, 1]

    alias Point = PointEnum(0)
    """
    2 dimensional Point.
    """
    alias PointZ = PointEnum(1)  
    """
    3 dimensional Point, has height or altitude (Z).
    """
    alias PointM = PointEnum(2)
    """
    3 dimensional Point, has measure (M).
    """
    alias PointZM = PointEnum(3)
    """
    4 dimensional Point, has height and measure  (ZM)
    """

    alias PointN = PointEnum(4)
    """
    5 or higher dimensional Point.
    """

    fn __init__(value: Int) -> Self:
        return Self { value: value }

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __str__(self) -> String:
        if self == PointEnum.Point:
            return "Point"
        if self == PointEnum.PointZ:
            return "PointZ"
        if self == PointEnum.PointM:
            return "PointM"
        if self == PointEnum.PointZM:
            return "PointZM"
        return "PointN"

@value
@register_passable("trivial")
struct Point[simd_dims: Int = 2, dtype: DType = DType.float64, T: PointEnum = PointEnum.Point](
    CollectionElement,
    Sized,
    Stringable
):
    """
    Point is a register-passable, copy-efficient struct holding 2 or more dimension values.
    
    ### Parameters

    - simd_dims: constrained to power of two (default = 2)
    - dtype: supports any float or integer type (default = float64)
    - T: enum type, ex: Point, PointZ, PointM, PointZM, or POINTN

    ### Memory Layouts

```txt

 Point2                 Empty Points are either NaN (float) max-finite (int).
┌───────────┬────────┐ ┌───────────┬────────┐
│SIMD index:│0   1   │ │SIMD index:│0   1   │
│dimension: │x   y   │ │dimension: │NaN NaN │
└───────────┴────────┘ └───────────┴────────┘

PointM (measure)
┌───────────┬──────────┐
│SIMD index:│0 1 2   3 │
│dimension: │x y NaN m │
└───────────┴──────────┘

PointZ (height)
┌───────────┬──────────┐
│SIMD index:│0 1 2 3   │
│dimension: │x y z NaN │
└───────────┴──────────┘

PointZM (height and measure)
┌───────────┬──────────┐
│SIMD index:│0 1 2 3   │
│dimension: │x y z m   │
└───────────┴──────────┘

PointN (n-dimensional point)
┌───────────┬───────────────────────┐
│SIMD index:│0  1  2  3  4  5  6  7 │
│dimension: │n0 n1 n2 n3 n4 n5 n6 n7│
└───────────┴───────────────────────┘
.
```


    """

    var coords: SIMD[dtype, simd_dims]

    fn __init__() -> Self:
        """
        Create Point with empty values (NaN for float or max finite for integers).
        """
        @parameter
        constrained[simd_dims % 2 == 0, "dims must be power of two"]()

        let empty = empty_value[dtype]()
        let coords = SIMD[dtype, simd_dims](empty)
        return Self { coords: coords }


    fn __init__(*coords_list: SIMD[dtype, 1]) -> Self:
        """
        Create Point from variadic list of SIMD values. Any missing elements are padded with empty values.
        """
        # TODO add arg for has_measure, has_height, so dimensions 3-4 can be encoded

        @parameter
        constrained[simd_dims % 2 == 0, "dims must be power of two"]()

        var result = Self()  # start with empty values
        let n = len(coords_list)
        debug_assert(n <= simd_dims, "coords_list length is longer than simd_dims parameter")

        for i in range(n):
            if i >= simd_dims:
                break
            result.coords[i] = coords_list[i]

        return result

    fn __init__(coords: SIMD[dtype, simd_dims]) -> Self:
        """
        Create Point from existing SIMD vector of coordinates.
        """
        @parameter
        constrained[simd_dims % 2 == 0, "dims must be power of two"]()

        return Self {coords: coords}

    fn has_height(self) -> Bool:
        if T == PointEnum.Point or T == PointEnum.PointM:
            return False
        alias z_idx = 2
        return not is_empty(self.coords[z_idx])

    fn has_measure(self) -> Bool:
        if T == PointEnum.Point or T == PointEnum.PointZ:
            return False
        alias m_idx = 3
        return not is_empty(self.coords[m_idx])

    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """
        Create Point from geojson (expect to have been parsed into a python dict).
        """
        let json_coords = json_dict["coordinates"]
        let coords_len = int(json_coords.__len__())
        var result = Self()
        print(simd_dims, dtype, T)
        print(len(result.coords))
        # print(str(result))
        return result
        # # TODO: bounds checking
        # for i in range(coords_len):
        #         result.coords[i] = json_coords[i].to_float64().cast[dtype]()
        # print(str(result))
        # return result

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
            raise Error("Invalid Point dims parameter vs. geoarrow: " + str(n))
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

        empty() and is_empty(). note, the zero point is not the same as an empty point!
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
        constrained[simd_dims >= 4, "Point has no Z dimension"]()

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
        constrained[simd_dims >= 4, "Point has no M dimension"]()
        return self.coords[3]

    fn __len__(self) -> Int:
        """
        Returns the number of non-empty dimensions.
        """
        if len(self.coords > 4):
            return len(self.coords)
        var dims = 2
        if self.has_height():
            dims += 1
        if self.has_measure():
            dims += 1
        return dims

    fn __getitem__(self, d: Int) -> SIMD[dtype, 1]:
        """
        Get the value of coordinate at this dimension.
        """
        return self.coords[d] if d < simd_dims else 0

    fn __eq__(self, other: Self) -> Bool:
        return Bool(self.coords == other.coords)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn enum(self) -> PointEnum:
        """
        Describe point's type as a PointEnum.
        """
        if self.has_height() and self.has_measure():
            return PointEnum.PointZM
        if self.has_height():
            return PointEnum.PointZ
        if self.has_measure():
            return PointEnum.PointM
        return PointEnum.Point

    fn __repr__(self) -> String:
        let desc = str(self.enum())
        var res =  desc +
            "[simd_dims:" +
            String(simd_dims) +
            ", dtype:" +
            dtype.__str__() +
            "]("
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
        # include only x, y, and optionally z (height)
        var res = String('{"type":"Point","coordinates":[')
        let dims = 3 if self.has_height() else 2
        for i in range(dims):
            if i > simd_dims - 1:
                break
            res += self.coords[i]
            if i < dims - 1:
                res += ","
            print(res)
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
        var result = str(self.enum())
        for i in range(simd_dims):
            result += self.coords[i]
            if i < simd_dims - 1:
                result += " "
        result += ")"
        return result

    fn is_empty(self) -> Bool:
        return is_empty[dtype, simd_dims](self.coords)
