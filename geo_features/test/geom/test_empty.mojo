from geo_features.geom.empty import empty_value, is_empty
from geo_features.test.pytest import MojoTest


fn main() raises:
    let test = MojoTest("empty_value")

    let empty_f64 = empty_value[DType.float64]()
    let empty_f32 = empty_value[DType.float32]()
    let empty_f16 = empty_value[DType.float16]()
    let empty_int = empty_value[DType.int32]()
    let empty_uint = empty_value[DType.uint32]()

    test.assert_true(is_empty(empty_f64), "empty_f64")
    test.assert_true(is_empty(empty_f32), "empty_f32")
    test.assert_true(is_empty(empty_f16), "empty_f16")
    test.assert_true(is_empty(empty_int), "empty_int")
    test.assert_true(is_empty(empty_uint), "empty_uint")

    test.assert_true(not is_empty[DType.float64, 1](42), "not empty")
    test.assert_true(not is_empty[DType.uint16, 1](42), "not empty")
