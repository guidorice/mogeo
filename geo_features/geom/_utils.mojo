from math import nan, isnan
from math.limit import max_finite


@always_inline
fn empty_value[dtype: DType]() -> SIMD[dtype, 1]:
    """
    Define a special value to mark empty slots or dimensions in structs. Required because SIMD must be power of two.
    """

    @parameter
    if dtype.is_floating_point():
        return nan[dtype]()
    else:
        return max_finite[dtype]()


@always_inline
fn is_empty[dtype: DType, simd_dims: Int](value: SIMD[dtype, simd_dims]) -> Bool:
    """
    Check for empty value.
    """
    return value == empty_value[dtype]()
