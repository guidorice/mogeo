trait Geoarrowable:
    """
    Serializable to and from GeoArrow representation of a Point.

    ### Spec

    - https://geoarrow.org/
    """

    @staticmethod
    fn from_geoarrow(table: PythonObject) raises -> Self:
        """
        Create Point from geoarrow / pyarrow table with geometry column.
        """
        ...

    fn geoarrow(self) -> PythonObject:
        ...
