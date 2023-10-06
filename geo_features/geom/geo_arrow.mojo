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
    Memory layout following the GeoArrow format.

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
        if self.coordinates != other.coordinates:
            return False
        #     [self.geometry_offsets, other.geometry_offsets],
        #     [self.part_offsets, other.part_offsets],
        #     [self.ring_offsets, other.ring_offsets],

        # let check = offset_checks.get[1, OffsetT]() 
        return True

    fn offsets_eq(self, other: Self) -> Bool:
        pass

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __len__(self) -> Int:
        """
        Length is same as num_coords.
        """
        return self.coordinates.shape()[1]