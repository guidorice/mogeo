from memory import memcmp
from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from utils.vector import DynamicVector, UnsafeFixedVector


alias GeoArrow2 = GeoArrow[DType.float32, 2]
alias GeoArrow3 = GeoArrow[DType.float32, 3]
alias GeoArrow4 = GeoArrow[DType.float32, 4]


@value
struct GeoArrow[dtype: DType, dims: Int]:
    """
    Memory layout following the GeoArrow format.

    ### Spec

    https://geoarrow.org
    """
    alias OffsetT = SIMD[dtype, 1]

    var coordinates: Tensor[dtype]
    var geometry_offsets: UnsafeFixedVector[OffsetT]
    var part_offsets: UnsafeFixedVector[OffsetT]
    var ring_offsets: UnsafeFixedVector[OffsetT]

    def __init__(inout self, num_features: Int):
        #  create column-oriented tensor (rows (dims) x cols (features))
        self.coordinates = Tensor[dtype](dims, num_features)
        # stub out empty offset vectors. consumers of GeoArrow must fill in offsets and not all of the offsets
        # vectors are needed depending on the feature class being modeled.
        self.geometry_offsets = UnsafeFixedVector[OffsetT](0)
        self.part_offsets = UnsafeFixedVector[OffsetT](0)
        self.ring_offsets = UnsafeFixedVector[OffsetT](0)
