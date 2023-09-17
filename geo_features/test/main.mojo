from geo_features.test.geom.test_point import main as test_point
from geo_features.test.geom.test_envelope import test_envelope
from geo_features.test.geom.test_line_string import test_line_string


fn main() raises:
    _ = test_envelope()
    # _ = test_point()
    # _ = test_line_string()
    print("🔥 test/main.mojo done")
