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
    Models an OGC-style LineString

    A LineString consists of a sequence of two or more vertices along with all points along the linearly-interpolated
    curves (line segments) between each pair of consecutive vertices. Consecutive vertices may be equal.

    The line segments in the line may intersect each other (in other words, the linestring may "curl back" in itself and
    self-intersect).

    - Linestrings with exactly two identical points are invalid.
    - Linestrings must have either 0 or 2 or more points.
    - If these conditions are not met, the constructors raise an Error.

    Coordinates of LineString are an array of positions:

    ```
    x1,y1
    x2,y2
    ...
    xn,yn
    ```

    ### Example

    ```
    _ = LineString2(Point2(-108.680, 38.974), Point2(-108.680, 38.974))

    var points_vec = DynamicVector[Point2](10)

    for n in range(0, 10):
        points_vec.push_back( Point2(lon + n, lat - n) )
    _ = LineString2(points_vec)
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

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __repr__(self) -> String:
        return "LineString[" + dtype.__str__() + ", "+ String(point_dims) +"](" + String(self.__len__()) + " points)"

    fn __getitem__(self: Self, index: Int) -> Point[dtype, point_dims]:
        """
        Get Point from LineString at index.
        """
        let x = self.coords[Index(index,0)]
        let y = self.coords[Index(index,1)]
        return Point[dtype, point_dims](x, y)

    fn __str__(self) -> String:
        return self.wkt()

    fn json(self) -> String:
        """
        """
        return ""
    
    fn wkt(self) -> String:
        """
        """
        return ""

    fn is_closed(self) -> Bool:
        """
        """
         return getCoordinateN(0).equals2D(getCoordinateN(getNumPoints() - 1));

        len len = self.__len__()
        let x1 = self.coords[Index(0, 0)]
        let y1 = self.coords[Index(0, 1)]
        let start_pt = Point[dtype, point_dims](x1, y1)

        let x2 = self.coords[Index(len-1, 0)]
        let y2 = self.coords[Index(len-1, 1)]
        let end_pt = Point[dtype, point_dims](x2, y2)

        return start_pt == end_pt

    
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
