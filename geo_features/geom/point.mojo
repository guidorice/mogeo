struct Point[dtype: DType, dims: Int]:
    """
    N-dimensional point, For example, x, y, z and m (measure).
    """
    var coords: SIMD[dtype, dims]
    
    fn __init__(inout self, coords: SIMD[dtype, dims]):
        self.coords = coords

    fn __init__(inout self, *elems: SIMD[dtype, 1]):
        for i in range(0, len(elems)):
            self.coords = elems
