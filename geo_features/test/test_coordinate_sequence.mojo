from geo_features.geom.coordinate_sequence import CoordinateSequence

alias CoordSeq2 = CoordinateSequence[DType.float32, DimList(8, 2)]


def test_coordinate_sequence_2d():
    print("# CoordinateSequence")

    let coords = CoordSeq2()
    coords.data.simd_store(
        0,
        SIMD[DType.float32, 16](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),
    )
    print("# elements:", coords.buffer.num_elements())

    # points represented in the coordinatee sequence as adjacent pairs:
    print("point2d:", coords.buffer[0, 0], coords.buffer[0, 1])
    print("point2d:", coords.buffer[1, 0], coords.buffer[1, 1])


alias CoordSeq3 = CoordinateSequence[DType.float32, DimList(8, 3)]


def test_coordinate_sequence_3d():
    print("# CoordinateSequence")

    let coords = CoordSeq3()
    coords.data.simd_store(
        0,
        SIMD[DType.float32, 16](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),
    )
    print("# elements:", coords.buffer.num_elements())

    # points represented in the coordinatee sequence as adjacent pairs:
    print("point3d:", coords.buffer[0, 0], coords.buffer[0, 1], coords.buffer[0, 2])
    print("point3d:", coords.buffer[1, 0], coords.buffer[1, 1], coords.buffer[1, 2])


alias CoordSeq4 = CoordinateSequence[DType.float32, DimList(8, 4)]


def test_coordinate_sequence_4d():
    print("# CoordinateSequence()")

    # how would a 4d point be represented (x, y, z, m) z = height, m = measure
    let coords = CoordSeq4()
    coords.data.simd_store(
        0,
        SIMD[DType.float32, 16](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),
    )
    print("# elements:", coords.buffer.num_elements())

    # points represented in the coordinatee sequence as adjacent pairs:
    print(
        "point4d:",
        coords.buffer[0, 0],
        coords.buffer[0, 1],
        coords.buffer[0, 2],
        coords.buffer[0, 3],
    )
    print(
        "point4d:",
        coords.buffer[1, 0],
        coords.buffer[1, 1],
        coords.buffer[1, 2],
        coords.buffer[0, 3],
    )


fn main() raises:
    _ = test_coordinate_sequence_2d()
    _ = test_coordinate_sequence_3d()
    _ = test_coordinate_sequence_4d()
