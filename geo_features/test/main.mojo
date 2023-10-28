from geo_features.test.geom.test_layout import main as test_layout
from geo_features.test.geom.test_envelope import main as test_envelope
from geo_features.test.geom.test_line_string import main as test_line_string
from geo_features.test.geom.test_multi_point import main as test_multi_point
from geo_features.test.geom.test_point import main as test_point


fn main() raises:
    test_layout()
    test_point()
    test_envelope()
    test_multi_point()
    test_line_string()

    print("🔥 test/main.mojo done")
