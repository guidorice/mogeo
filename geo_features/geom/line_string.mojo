from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector
from sys.info import simdwidthof, simdbitwidth
from memory import memcmp

from geo_features.inter import WKTParser, JSONParser
from .point import Point

alias LineString2 = LineString[DType.float32, 2]
alias LineString3 = LineString[DType.float32, 3]
alias LineString4 = LineString[DType.float32, 4]

alias LinearRing2 = LineString[DType.float32, 2]
alias LinearRing3 = LineString[DType.float32, 3]
alias LinearRing4 = LineString[DType.float32, 4]


struct LineString[dtype: DType, point_dims: Int]:

    """
    Coordinates of LineString are an array of positions.

    ```
    x1,y1
    x2,y2
    ...
    xn,yn
    ```
    """
    var coords: Tensor[dtype]

    fn __init__(inout self, *points: Point[dtype, point_dims]):
        """
        Create LineString from a variadic (var args) list of Points.
        """
        let args = VariadicList(points)
        let height = len(args)
        let width = point_dims
        let spec = TensorSpec(dtype, height, width)
        self.coords = Tensor[dtype](spec)
        for y in range(0, height):
            for x in range(0, width):
                self.coords[Index(y,x)] = args[y].coords[x]

    fn __init__(inout self, points: DynamicVector[Point[dtype, point_dims]]):
        """
        Create LineString from a vector of Points.
        """
        let height = len(points)
        let width = point_dims
        let spec = TensorSpec(dtype, height, width)
        self.coords = Tensor[dtype](spec)
        for y in range(0, height):
            for x in range(0, width):
                self.coords[Index(y,x)] = points[y].coords[x]

    fn __copyinit__(inout self, other: Self):
        self.coords = other.coords

    # @staticmethod
    # fn from_json(json_dict: PythonObject) raises -> LineString[dtype]:
    #     """
    #     """
    #     pass

    # @staticmethod
    # fn from_json(json_str: String) raises -> LineString[dtype]:
    #     """
    #     """
    #     pass

    # @staticmethod
    # def from_wkt(wkt: String) ->  LineString[dtype]:
    #     """
    #     """

    fn __len__(self) -> Int:
        return self.coords.shape()[0]

    fn _sloweq(self, other: Self) -> Bool:
        """
        Procedural equality check (see __eq__())
        """
        let len = self.__len__()
        if len != other.__len__():
            return False
        for i in range(0, len):
            if self[i] != other[i]:
                return False
        return True

    # fn __eq__(self, other: Self) -> Bool:
    #     """
    #     Equality check by direct memory comparison of 2 tensors buffers.
    #     """
    #     let len = self.__len__()
    #     if len != other.__len__():
    #         return False
    #     let self_buffer = self.coords.data()
    #     let other_buffer = other.coords.data()
    #     let n = len * point_dims
    #     return memcmp[dtype](self_buffer, other_buffer, n) == 0

    fn __eq__(self, other: Self) -> Bool:
        """
        Equality check by direct memory comparison of 2 tensors buffers.
        """
        let n = self.coords.num_elements()
        if n != other.coords.num_elements():
            return False
        let self_buffer = self.coords.data()
        let other_buffer = other.coords.data()
        return memcmp[dtype](self_buffer, other_buffer, n) == 0

    # fn __eq__(self, other: Self) -> Bool:
    #     """
    #     Equality check by direct memory comparison of respective buffers.
    #     """
    #     if self.shape() != other.shape()
    #         return False
    #     let self_buffer = self.data()
    #     let other_buffer = other.data()
    #     let n = self.num_elements() * self.rank()
    #     return memcmp[dtype](self_buffer, other_buffer, n) == 0

    # fn __eq__(self, other: Self) -> Bool:
    #     """
    #     Vectorized equality check (approx 27X faster than procedural version in _sloweq)
    #     """
    #     let len = self.__len__()
    #     alias nelts = simdwidthof[Point[dtype, point_dims]]()
    #     let n = len * point_dims

    #     if len != other.__len__():
    #         return False

    #     for i in range(0, n, nelts):
    #         var self_vec = self.coords.simd_load[nelts](i)
    #         var other_vec = other.coords.simd_load[nelts](i)
    #         # the last batch of nelts may not fill the vector, so write zeros so equality check can still be valid
    #         if n - i < nelts:
    #             for j in range(n - i, n):
    #                 self_vec[j] = 0
    #                 other_vec[j] = 0
    #         let vectors_eq = self_vec == other_vec
    #         if not Bool(vectors_eq):
    #             return False

    #     return True

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return "LineString[" + dtype.__str__() + ", "+ String(point_dims) +"](" + String(self.__len__()) + " points)"

    fn __getitem__(self: Self, index: Int) -> Point[dtype, point_dims]:
        """
        Get Point from LineString at index
        """
        let x = self.coords[Index(index,0)]
        let y = self.coords[Index(index,1)]
        return Point[dtype, point_dims](x, y)

    # fn __str__(self) -> String:
    #     return self.wkt()

    # fn json(self) -> String:
    #     """
    #     """
    #     return res
    
    # fn wkt(self) -> String:
    #     """
    #     """
    #     pass

    fn is_closed(self) -> Bool:
        return False
    
    fn is_ring(self) -> Bool:
        return self.is_closed() and self.is_simple()

    fn is_simple(self) -> Bool:
        """
        A geometry is simple if it has no points of self-tangency, self-intersection or other anomalous points.
        """
        # TODO add check for these geometry simplicity conditions
        return True
    
    fn is_empty(self) -> Bool:
      return self.__len__() == 0
