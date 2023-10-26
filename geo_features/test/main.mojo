from geo_features.test.geom.test_envelope import test_envelope
# from geo_features.test.geom.test_line_string import main as test_line_string
# from geo_features.test.geom.test_multi_point import test_multi_point
from geo_features.test.geom.test_point import main as test_point
from geo_features.test.geom.test_geo_arrow import test_geo_arrow


fn main() raises:
    test_geo_arrow()
    test_point()
    # test_multi_point()
    test_envelope()
    # test_line_string()

    print("🔥 test/main.mojo done")
