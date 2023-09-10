from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index

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
    """
    var coords: Tensor[dtype]

    fn __init__(inout self, *points: Point[dtype, point_dims]):
        """
        Create LineString from variadic list of Points.
        """
        let args = VariadicList(points)
        let height = len(args)
        let width = point_dims
        let spec = TensorSpec(dtype, height, width)
        self.coords = Tensor[dtype](spec)
        for y in range(0, height):
            for x in range(0, width):
                self.coords[Index(y,x)] = args[y].coords[x]

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

    # fn __eq__(self, other: Self) -> Bool:
    #     return Bool(self.tensor == other.tensor)

    # fn __ne__(self, other: Self) -> Bool:
    #     return not self.__eq__(other)

    fn __repr__(self) -> String:
        var res = "LineString[" + dtype.__str__() + ", "+ String(point_dims) +"](...)"
        return res

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
