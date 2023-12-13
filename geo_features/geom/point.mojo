from python import Python
from math import nan, isnan
from math.limit import max_finite

from geo_features.geom.empty import empty_value, is_empty
from geo_features.serialization import WKTParser, WKTable, JSONParser, JSONable, Geoarrowable
from .traits import Geometric, Emptyable
from .enums import CoordDims


@value
@register_passable("trivial")
struct Point[dtype: DType = DType.float64](
    CollectionElement,
    Geoarrowable,
    Geometric,
    Emptyable,
    JSONable,
    Sized,
    Stringable,
    WKTable,
):
    """
Point is a register-passable, copy-efficient struct holding 2 or more dimension values.

### Parameters

    - dtype: supports any float or integer type (default = float64)

### Memory Layouts

    Some examples of memory layout using Mojo SIMD variables.

```txt

```
    """
    alias simd_dims = 4
    alias x_index = 0
    alias y_index = 1
    alias z_index = 2
    alias m_index = 3

    var coords: SIMD[dtype, Self.simd_dims]
    var ogc_dims: CoordDims

    #
    # Constructors
    #
    fn __init__(dims: CoordDims = CoordDims.Point) -> Self:
        """
        Create Point with empty values (NaN for float or max finite for integers).
        """
        let empty = empty_value[dtype]()
        let coords = SIMD[dtype, Self.simd_dims](empty)
        return Self { coords: coords, ogc_dims: dims }

    fn __init__(*coords_list: SIMD[dtype, 1]) -> Self:
        """
        Create Point from variadic list of SIMD values. Any missing elements are padded with empty values.

        ### See also

        Setter method for ogc_dims enum. May be useful when Point Z vs Point M is ambiguous in this constructor.
        """
        let empty = empty_value[dtype]()
        var coords = SIMD[dtype, Self.simd_dims](empty)
        var ogc_dims = CoordDims.Point
        let n = len(coords_list)

        for i in range(Self.simd_dims):
            if i < n:
                coords[i] = coords_list[i]

        if n == 3:
            ogc_dims = CoordDims.PointZ
            # workaround in case this is a Point M (measure). Duplicate the measure value in index 2 and 3.
            coords[Self.m_index] = coords[Self.z_index]
        elif n >= 4:
            ogc_dims = CoordDims.PointZM

        return Self { coords: coords, ogc_dims: ogc_dims }

    fn __init__(coords: SIMD[dtype, Self.simd_dims], dims: CoordDims = CoordDims.Point) -> Self:
        """
        Create Point from existing SIMD vector of coordinates.
        """
        return Self {coords: coords, ogc_dims: dims}

    #
    # Static constructor methods.
    #
    @staticmethod
    fn from_json(json_dict: PythonObject) raises -> Self:
        """
        JSONable trait.
        """
        # TODO: bounds checking of coords_len
        let json_coords = json_dict["coordinates"]
        let coords_len = int(json_coords.__len__())
        var result = Self()
        for i in range(coords_len):
            result.coords[i] = json_coords[i].to_float64().cast[dtype]()
        return result

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        """
        JSONable trait.
        """
        let json_dict = JSONParser.parse(json_str)
        return Self.from_json(json_dict)

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        """
        WKTable trait.
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
        Geoarrowable trait.
        """
        let ga = Python.import_module("geoarrow.pyarrow")
        let geoarrow = ga.as_geoarrow(table["geometry"])
        let chunk = geoarrow[0]
        let n = chunk.value.__len__()
        if n > Self.simd_dims:
            raise Error("Invalid Point dims parameter vs. geoarrow: " + str(n))
        var result = Self()
        for dim in range(n):
            let val = chunk.value[dim].as_py().to_float64().cast[dtype]()
            result.coords[dim] = val
        return result

    @staticmethod
    fn empty(dims: CoordDims = CoordDims.Point) -> Self:
        """
        Emptyable trait.
        """
        return Self.__init__(dims)

    #
    # Getters/Setters
    #
    fn set_ogc_dims(inout self, ogc_dims: CoordDims):
        """
        Setter for ogc_dims enum. May be useful if the Point constructor with variadic list of coordinate values.
        (Point Z vs Point M is ambiguous).
        """
        self.ogc_dims = ogc_dims

    fn dims(self) -> SIMD[DType.uint8, 1]:
        """
        Dimensionable trait.
        """
        if self.ogc_dims == CoordDims.Point:
            return 2
        elif self.ogc_dims == CoordDims.PointM or self.ogc_dims == CoordDims.PointZ:
            return 3
        elif self.ogc_dims == CoordDims.PointZM:
            return 4
        else:
            debug_assert(False, "Invalid ogc_dims value")


    fn has_height(self) -> Bool:
        return (self.ogc_dims == CoordDims.PointZ) or (self.ogc_dims == CoordDims.PointZM)

    fn has_measure(self) -> Bool:
        return (self.ogc_dims == CoordDims.PointM) or (self.ogc_dims == CoordDims.PointZM)

    fn is_empty(self) -> Bool:
        return is_empty[dtype](self.coords)

    @always_inline
    fn x(self) -> SIMD[dtype, 1]:
        """
        Get the x value (0 index).
        """
        return self.coords[self.x_index]

    @always_inline
    fn y(self) -> SIMD[dtype, 1]:
        """
        Get the y value (1 index).
        """
        return self.coords[self.y_index]

    @always_inline
    fn z(self) -> SIMD[dtype, 1]:
        """
        Get the z or altitude value (2 index).
        """
        return self.coords[self.z_index]

    @always_inline
    fn alt(self) -> SIMD[dtype, 1]:
        """
        Get the z or altitude value (2 index).
        """
        return self.z()

    @always_inline
    fn m(self) -> SIMD[dtype, 1]:
        """
        Get the measure value (3 index).
        """
        return self.coords[self.m_index]

    #
    # Dunder methods
    #
    fn __len__(self) -> Int:
        """
        Returns the number of non-empty dimensions.
        """
        return self.dims().to_int()

    fn __getitem__(self, d: Int) -> SIMD[dtype, 1]:
        """
        Get the value of coordinate at this dimension.
        """
        return self.coords[d] if d < Self.simd_dims else empty_value[dtype]()

    fn __eq__(self, other: Self) -> Bool:
        # NaN is used as empty value, so here cannot simply compare with __eq__ on the SIMD values.
        @unroll
        for i in range(Self.simd_dims):
            if is_empty(self.coords[i]) and is_empty(other.coords[i]):
               pass  # equality at index i
            else:
                if is_empty(self.coords[i]) or is_empty(other.coords[i]):
                    return False  # early out: one or the other is empty (but not both) -> not equal
                if self.coords[i] != other.coords[i]:
                    return False  # not equal
        return True  # equal

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        let point_variant = str(self.ogc_dims)
        var res =  point_variant + " [" + dtype.__str__() + "]("
        for i in range(Self.simd_dims):
            res += str(self.coords[i])
            if i < Self.simd_dims -1:
                res += ", "
        res += ")"
        return res

    fn __str__(self) -> String:
        """
        Convert to String, uses WKT for convenience. See also __repr__().
        """
        return self.wkt()

    fn json(self) -> String:
        """
        JSONable trait.
        """
        # include only x, y, and optionally z (height)
        var res = String('{"type":"Point","coordinates":[')
        let dims = 3 if self.has_height() else 2
        for i in range(dims):
            if i > 3:
                break
            res += self.coords[i]
            if i < dims - 1:
                res += ","
        res += "]}"
        return res

    fn wkt(self) -> String:
        """
        See WKTable trait.
        """
        if self.is_empty():
            return "POINT EMPTY"
        var result = str(self.ogc_dims) + " ("
        result += str(self.x()) + " " + str(self.y())
        if self.ogc_dims == CoordDims.PointZ or self.ogc_dims == CoordDims.PointZM:
            result += " " + str(self.z())
        if self.ogc_dims == CoordDims.PointM or self.ogc_dims == CoordDims.PointZM:
            result += " " + str(self.m())
        result += ")"
        return result

    fn geoarrow(self) -> PythonObject:
        """
        See Geoarrowable trait.
        """
        # TODO: geoarrow()
        return None
