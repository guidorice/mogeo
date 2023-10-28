from memory import memcmp
from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector, UnsafeFixedVector


alias Layout2 = Layout[DType.float32, 2]
alias Layout3 = Layout[DType.float32, 3]
alias Layout4 = Layout[DType.float32, 4]
alias OffsetT = DType.uint16

@value
struct Layout[dtype: DType, dims: Int]:
    """
    Memory layout inspired by, but not exactly following, the GeoArrow format.

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
        """
        Check equality of coordinates and offsets vs other.
        """
        if self.coordinates == other.coordinates and
            self.geometry_offsets == other.geometry_offsets and
            self.part_offsets == other.part_offsets and
            self.ring_offsets == other.ring_offsets:
            return True
        return False

    fn __ne__(self, other: Self) -> Bool:
        """
        Check in-equality of coordinates and offsets vs other.
        """
        return not self.__eq__(other)

    fn __len__(self) -> Int:
        """
        Length is the number of coordinates, and is the constructor's `coords_size` argument.
        """
        return self.coordinates.shape()[1]
