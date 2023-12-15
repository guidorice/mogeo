from math.limit import max_finite
from tensor import Tensor

from .traits import Dimensionable
from .enums import CoordDims


@value
struct Layout[dtype: DType = DType.float64, offset_dtype: DType = DType.uint32](
    Sized, Dimensionable
):
    """
    Memory layout inspired by, but not exactly following, the GeoArrow format.

    ### Spec

    https://geoarrow.org
    """

    alias dimensions_idx = 0
    alias features_idx = 1

    var coordinates: Tensor[dtype]
    var geometry_offsets: Tensor[offset_dtype]
    var part_offsets: Tensor[offset_dtype]
    var ring_offsets: Tensor[offset_dtype]
    var ogc_dims: CoordDims

    fn __init__(
        inout self,
        ogc_dims: CoordDims = CoordDims.Point,
        coords_size: Int = 0,
        geoms_size: Int = 0,
        parts_size: Int = 0,
        rings_size: Int = 0,
    ):
        """
        Create column-oriented tensor: rows (dims) x cols (coords), plus offsets vectors.
        """
        if max_finite[offset_dtype]() < coords_size:
            print(
                "Warning: offset_dtype parameter not large enough for coords_size arg.",
                offset_dtype,
                coords_size,
            )
        self.ogc_dims = ogc_dims
        self.coordinates = Tensor[dtype](len(ogc_dims), coords_size)
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
        Length is the number of coordinates (constructor's `coords_size` argument)
        """
        return self.coordinates.shape()[self.features_idx]

    fn dims(self) -> Int:
        """
        Num dimensions (X, Y, Z, M, etc). (constructor's `dims` argument).
        """
        return self.coordinates.shape()[self.dimensions_idx]

    fn has_height(self) -> Bool:
        return self.ogc_dims == CoordDims.PointZ or self.ogc_dims == CoordDims.PointZM

    fn has_measure(self) -> Bool:
        return self.ogc_dims == CoordDims.PointM or self.ogc_dims == CoordDims.PointZM
