from geo_features.test.geom.test_coordinate_sequence import test_coordinate_sequence
from geo_features.test.geom.test_point import main as test_point
from geo_features.test.geom.test_line_string import test_line_string


fn main() raises:
    _ = test_point()
    # _ = test_line_string()
    # _ = test_coordinate_sequence()
    print("🔥 test/main.mojo")
