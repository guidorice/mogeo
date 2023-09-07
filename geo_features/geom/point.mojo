alias Point2 = Point[DType.float32, 2]
alias Point3 = Point[DType.float32, 3]
alias Point4 = Point[DType.float32, 4]


@register_passable("trivial")
struct Point[dtype: DType, dims: Int]:
    """
    N-dimensional point, For example, x, y, z and m (measure).
    """
    var coords: SIMD[dtype, dims]
    
    fn __init__(owned coords: SIMD[dtype, dims]) -> Self:
        # self.coords = coords
        return Point[dtype, dims]{ coords: coords }

    fn __init__(*elems: SIMD[dtype, 1]) -> Self:
        # TODO: when argument unpacking is supported, consider removing the variadic list creation here?
        let list = VariadicList(elems)
        var coords = SIMD[dtype, dims]()
        for i in range(0, len(list)):
            coords[i] = elems[i]
        return Point[dtype, dims]{ coords: coords }

    fn x(self) -> SIMD[dtype, 1]:
        return self.coords[0]

    fn y(self) -> SIMD[dtype, 1]:
        return self.coords[1]

    fn z(self) -> SIMD[dtype, 1]:
        return self.coords[2] if dims >= 3 else 0

    fn m(self) -> SIMD[dtype, 1]:
        return self.coords[3] if dims >= 4 else 0

    fn __eq__(self, other: Self) -> Bool:
        return Bool(self.coords == other.coords)

    fn __ne__(self, other: Self) -> Bool:
        return not Bool(self.coords == other.coords)

    fn __str__(self) -> String:
        # TODO f-string here
        var descr = "Point[" + dtype.__str__() + ", " + String(dims) + "]{"+ String(self.x()) + ", " + String(self.y())
        if dims > 2:
            descr += ", "+ String(self.z())
        if dims == 4:
            descr += ", "+ String(self.m())
        return descr