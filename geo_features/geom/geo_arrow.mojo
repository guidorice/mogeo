from memory import memcmp
from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector, UnsafeFixedVector


alias GeoArrow2 = GeoArrow[DType.float32, 2]
alias GeoArrow3 = GeoArrow[DType.float32, 3]
alias GeoArrow4 = GeoArrow[DType.float32, 4]
alias OffsetT = Int

@value
struct GeoArrow[dtype: DType, dims: Int]:
    """
    Memory layout following the GeoArrow format.

    ### Spec

    https://geoarrow.org
    """

    var coordinates: Tensor[dtype]
    var geometry_offsets: Tensor[OffsetT]
    var part_offsets: Tensor[OffsetT]
    var ring_offsets: Tensor[OffsetT]

    fn __init__(inout self, coords_size: Int, geoms_size: Int, parts_size: Int, rings_size: Int):
        """
        Create column-oriented tensor: rows (dims) x cols (coords), and offsets vectors.
        """
        self.coordinates = Tensor[dtype](dims, coords_size)
        self.geometry_offsets = Tensor[OffsetT](geoms_size)
        self.part_offsets = Tensor[OffsetT](parts_size)
        self.ring_offsets = Tensor[OffsetT](rings_size)

    fn __eq__(self, other: Self) -> Bool:
        if self.coordinates == other.coordinates and
            self.geometry_offsets == other.geometry_offsets and
            self.part_offsets == other.part_offsets and
            self.ring_offsets == other.ring_offsets:
            return True
        return False

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __len__(self) -> Int:
        """
        Length is same as num_coords.
        """
        return self.coordinates.shape()[1]