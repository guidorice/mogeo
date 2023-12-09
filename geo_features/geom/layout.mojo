from math.limit import max_finite
from tensor import Tensor


@value
struct Layout[coord_dtype: DType = DType.float64, offset_dtype: DType = DType.uint32](
    Sized
):
    """
    Memory layout inspired by, but not exactly following, the GeoArrow format.

    ### Spec

    https://geoarrow.org
    """

    var coordinates: Tensor[coord_dtype]
    var geometry_offsets: Tensor[offset_dtype]
    var part_offsets: Tensor[offset_dtype]
    var ring_offsets: Tensor[offset_dtype]

    fn __init__(
        inout self,
        dims: Int = 2,
        coords_size: Int = 0,
        geoms_size: Int = 0,
        parts_size: Int = 0,
        rings_size: Int = 0,
    ):
        """
        Create column-oriented tensor: rows (dims) x cols (coords), and offsets vectors.
        """
        if max_finite[offset_dtype]() < coords_size:
            print(
                "Warning: offset_dtype parameter not large enough for coords_size arg.",
                offset_dtype,
                coords_size,
            )
        self.coordinates = Tensor[coord_dtype](dims, coords_size)
        self.geometry_offsets = Tensor[offset_dtype](geoms_size)
        self.part_offsets = Tensor[offset_dtype](parts_size)
        self.ring_offsets = Tensor[offset_dtype](rings_size)

    fn __eq__(self, other: Self) -> Bool:
        """
        Check equality of coordinates and offsets vs other.
        """
        if (
            self.coordinates == other.coordinates
            and self.geometry_offsets == other.geometry_offsets
            and self.part_offsets == other.part_offsets
            and self.ring_offsets == other.ring_offsets
        ):
            return True
        return False

    fn __ne__(self, other: Self) -> Bool:
        """
        Check in-equality of coordinates and offsets vs other.
        """
        return not self == other

    fn __len__(self) -> Int:
        """
        Length is the number of coordinates, and is the constructor's `coords_size` argument.
        """
        return self.coordinates.shape()[1]

    fn dims(self) -> Int:
        """
        Dims is the dimensions argument.
        """
        return self.coordinates.shape()[0]
