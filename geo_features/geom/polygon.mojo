# from geo_features.inter import WKTParser, JSONParser
# from .coordinate_sequence import CoordinateSequence

# alias Polygon2 = Polygon[DType.float32, 2]
# """
# Alias for 2D polygon with dtype: float32.
# """

# alias Polygon3 = Polygon[DType.float32, 4]
# """
# Alias for 3D polygon with dtype float32. Note: is backed by SIMD vector of size 4 (must be power of two).
# """

# alias Polygon4 = Polygon[DType.float32, 4]
# """
# Alias for 4D polygon with dtype float32.
# """

# struct Polygon[dtype: DType, dims: Int]:
#     """
#     Polygon is a plane figure made up of line segments connected to form a closed polygonal chain. 
#     """
#     var coords: CoordinateSequence[DType.float32, DimList(8, 2)]
#     var adjacency_matrix: CoordinateSequence[DType.bool, DimList(8, 2)]

#     fn __init__(*elems: SIMD[dtype, 1]) -> Self:
#         """
#         """
#         pass

#     fn __init__(owned coords: SIMD[dtype, dims]) -> Self:
#         """
#         """
#         pass

#     @staticmethod
#     fn from_json(json_dict: PythonObject) raises -> Polygon[dtype, dims]:
#         """
#         """
#         pass

#     @staticmethod
#     fn from_json(json_str: String) raises -> Polygon[dtype, dims]:
#         """
#         """
#         pass

#     @staticmethod
#     def from_wkt(wkt: String) -> Polygon[dtype, dims]:
#         """
#         """
#         pass

#     @staticmethod
#     fn zero() -> Polygon[dtype, dims]:
#         """
#         Null Island is an imaginary place located at zero degrees latitude and zero degrees longitude (0°N 0°E)
#         https://en.wikipedia.org/wiki/Null_Island .
#         """
#         pass


#     fn __eq__(self, other: Self) -> Bool:
#         # return Bool(self.coords == other.coords)
#         return False

#     fn __ne__(self, other: Self) -> Bool:
#         return not self.__eq__(other)

#     fn __repr__(self) -> String:
#         var res = "Polygon[" + dtype.__str__() + ", " + String(dims) + "](TODO)"
#         return res

#     fn __str__(self) -> String:
#         return self.wkt()

#     fn json(self) -> String:
#         """
#         GeoJSON representation of Polygon.

#         Example:

#         ```json
#         ```

#         ### Spec

#         - https://geojson.org
#         - https://datatracker.ietf.org/doc/html/rfc7946
#         """
#         # include only x, y, and optionally z (altitude)
#         pass
    
#     fn wkt(self) -> String:
#         """
#         Well Known Text (WKT) representation of Polygon.

#         ### Spec

#         - https://libgeos.org/specifications/wkt
#         """
#         pass
