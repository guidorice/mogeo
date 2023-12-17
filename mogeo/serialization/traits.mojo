trait WKTable:
    """
    Serializable to and from Well Known Text (WKT).

    ### Specs

    - https://libgeos.org/specifications/wkt
    - https://www.ogc.org/standard/sfa/
    - https://www.ogc.org/standard/sfs/
    """

    @staticmethod
    fn from_wkt(wkt: String) raises -> Self:
        ...

    fn wkt(self) -> String:
        ...


trait JSONable:
    """
    Serializable to and from GeoJSON representation of Point. Point coordinates are in x, y order (easting, northing for
    projected coordinates, longitude, and latitude for geographic coordinates).

    ### Specs

    - https://geojson.org
    - https://datatracker.ietf.org/doc/html/rfc7946
    """

    @staticmethod
    fn from_json(json: PythonObject) raises -> Self:
        ...

    @staticmethod
    fn from_json(json_str: String) raises -> Self:
        ...

    fn json(self) raises -> String:
        """
        Serialize to GeoJSON format.

        ### Raises Error

        Error is raised for PointM and PointZM, because measure and other higher dimensions are not part of the GeoJSON
        spec.

        > An OPTIONAL third-position element SHALL be the height in meters above or below the WGS 84 reference
        > ellipsoid. (RFC 7946)
        """
        ...


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

    # TODO: to geoarrow
    # fn geoarrow(self) -> PythonObject:
    #     ...
