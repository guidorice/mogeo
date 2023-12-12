from python import Python
from python.object import PythonObject


trait JSONable:
    """
    Serializable to and from GeoJSON representation of Point. Point coordinates are in x, y order (easting, northing for
    projected coordinates, longitude, and latitude for geographic coordinates).

    ### Spec

    - https://geojson.org
    - https://datatracker.ietf.org/doc/html/rfc7946
    """

    @staticmethod
    fn from_json(json: PythonObject) raises -> Self:
        ...

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        ...

    fn json(self) -> String:
        ...


struct JSONParser:
    @staticmethod
    fn parse(json_str: String) raises -> PythonObject:
        """
        Wraps json parser implementation.
        """
        let orjson = Python.import_module("orjson")
        return orjson.loads(json_str)
