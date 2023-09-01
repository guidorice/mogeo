struct Point[dtype: DType, dims: Int]:
    """
    N-dimensional point, For example, x, y, z and m (measure).
    """
    var coords: SIMD[dtype, dims]   
    
    fn __init__(inout self):
        pass
