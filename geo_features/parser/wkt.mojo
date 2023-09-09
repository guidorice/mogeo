from python import Python
from python.object import PythonObject

# TODO: optimization: call GEOS C library wkt parser directly instead of going through python/shapely

struct WKTParser:

    @staticmethod
    fn parse(wkt: String) raises -> PythonObject:
        let shapely = Python.import_module("shapely")
        return shapely.from_wkt(wkt)
