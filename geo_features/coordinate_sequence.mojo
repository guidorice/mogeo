from memory.buffer import NDBuffer
from memory.memory import memset_zero

@value
struct CoordinateSequence[dtype: DType, shape: DimList]:
    """
    The internal representation of a list of coordinates inside a Geometry.
    """
    var data: DTypePointer[dtype]
    var buffer: NDBuffer[shape.__len__(), shape, dtype]

    fn __init__(inout self):
        let size = shape.product[shape.__len__()]().get()
        self.data = DTypePointer[dtype].alloc(size)
        memset_zero(self.data, size)
        self.buffer = NDBuffer[shape.__len__(), shape, dtype](self.data)

    fn __del__(owned self):
        self.data.free()
