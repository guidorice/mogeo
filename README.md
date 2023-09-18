# geo_features

`geo_features` is a [Mojo](https://github.com/modularml/mojo) package for geographic or geometric vector features,
for example: location data or earth observation data. It is based upon
[GeoJSON](https://datatracker.ietf.org/doc/html/rfc7946) and
[ISO/OGC Simple Features](https://en.wikipedia.org/wiki/Simple_Features/) specs and the
[JTS Topology Suite](https://github.com/locationtech/jts) library.

## project goals

- Promote cloud native geospatial computing and open geospatial standards.
- Benefit from the existing Python ecosystem, wherever possible to enable rapid development.
- Although `geo_features` is intended to be a performant alternative to the
[Shapely](https://github.com/shapely/shapely) Python package, it interoperates
with Shapely as well. Examples: parsing WKT, and units tests for comparison of results with Shapely.
- Interoperate with Python's scientific computing ecosystem including NumPy,
Pandas and the [Python array API standard](https://data-apis.org/array-api/latest).

## roadmap

### structs

- [ ] Envelope
- [ ] Feature
- [ ] FeatureCollection
- [ ] GeometryCollection
- [ ] LinearRing
- [ ] MultiLineString
- [ ] MultiPoint
- [ ] MultiPolygon
- [ ] Polygon
- [x] LineString
- [x] Point

### interchange formats

- [x] Well Known Text (WKT)
- [x] GeoJSON
- [ ] GeoParquet
- [ ] TopoJSON

### methods

- [ ] area
- [ ] perimeter
- [ ] centroid
- [ ] intersection
- [ ] union
- [ ] difference

### algorithms

- [ ] parallelized+vectorized spatial join
- [ ] rasterize from vector
- [ ] vectorize from raster
- [ ] re-projection and CRS support
- [ ] simplify or decimate
- [ ] stratified sampling?
- [ ] zonal stats?
- [ ] smart antimeridian crossing mode (quaternions?)

## architectural decisions
