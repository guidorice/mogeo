from python import Python
from python.object import PythonObject

trait WKTable:
    """
    Serializable to and from Well Known Text (WKT).

    ### Spec

    https://libgeos.org/specifications/wkt
    """

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        ...

    fn wkt(self) -> String:
        ...


struct WKTParser:
    @staticmethod
    fn parse(wkt: String) raises -> PythonObject:
        let shapely = Python.import_module("shapely")
        return shapely.from_wkt(wkt)
