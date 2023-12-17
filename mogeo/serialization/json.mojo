from python import Python
from python.object import PythonObject


struct JSONParser:
    @staticmethod
    fn parse(json_str: String) raises -> PythonObject:
        """
        Wraps json parser implementation.
        """
        let orjson = Python.import_module("orjson")
        return orjson.loads(json_str)
