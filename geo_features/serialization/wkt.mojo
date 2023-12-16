from python import Python
from python.object import PythonObject


struct WKTParser:
    @staticmethod
    fn parse(wkt: String) raises -> PythonObject:
        """
        Wraps shapely.from_wkt to convert WKT string to a Shapely object.
        """
        let shapely = Python.import_module("shapely")
        return shapely.from_wkt(wkt)
