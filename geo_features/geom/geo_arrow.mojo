from memory import memcmp
from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector, UnsafeFixedVector


alias GeoArrow2 = GeoArrow[DType.float32, 2]
alias GeoArrow3 = GeoArrow[DType.float32, 3]
alias GeoArrow4 = GeoArrow[DType.float32, 4]
alias OffsetT = SIMD[DType.uint32, 1]


@value
struct GeoArrow[dtype: DType, dims: Int]:
    """
    Memory layout (approximately) following the GeoArrow format.

    ### Spec

    https://geoarrow.org
    """

    var coordinates: Tensor[dtype]
    var geometry_offsets: UnsafeFixedVector[OffsetT]
    var part_offsets: UnsafeFixedVector[OffsetT]
    var ring_offsets: UnsafeFixedVector[OffsetT]

    fn __init__(inout self, coords_size: Int, geoms_size: Int, parts_size: Int, rings_size: Int):
        """
        Create column-oriented tensor: rows (dims) x cols (coords), and offsets vectors.
        """
        self.coordinates = Tensor[dtype](dims, coords_size)
        self.geometry_offsets = UnsafeFixedVector[OffsetT](geoms_size)
        self.part_offsets = UnsafeFixedVector[OffsetT](parts_size)
        self.ring_offsets = UnsafeFixedVector[OffsetT](rings_size)

    fn __eq__(self, other: Self) -> Bool:
        """
        Equality check by direct memory comparison of 2 tensors buffers.
        """
        let n = self.coordinates.num_elements()
        if n != other.coordinates.num_elements():
            return False
        let self_buffer = self.coordinates.data()
        let other_buffer = other.coordinates.data()
        return memcmp[dtype](self_buffer, other_buffer, n) == 0

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __len__(self) -> Int:
        """
        Length is same as num_coords.
        """
        return self.coordinates.shape()[1]