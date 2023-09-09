# geo_features

`geo_features` is a [Mojo](https://github.com/modularml/mojo) package for geographic or geometric vector features,
for example location data or earth observation data. It is guided by the
[GeoJSON](https://datatracker.ietf.org/doc/html/rfc7946) and
[OGC Simple Features](https://www.ogc.org/standards/) specs.

## project goals

- Promote cloud native geospatial computing and open geospatial standards.
- Benefit from the existing Python ecosystem, wherever possible to enable rapid development.
  - Although `geo_features` is intended to be performant alternative to the [Shapely](https://github.com/shapely/shapely) Python package, it calls into
    Python to run Shapely in places as well. Examples: parsing WKT, and units tests and comparison of results with Shapely.
- Interoperate with Python's scientific computing ecosystem including NumPy, Pandas and the [Python array API
  standard](https://data-apis.org/array-api/latest).

## roadmap

### structs

- [ ] AdjacencyMatrix
- [ ] BoundingBox
- [x] CoordinateSequence
- [ ] Feature
- [ ] FeatureCollection
- [ ] GeometryCollection
- [ ] LineString
- [ ] MultiLineString
- [ ] MultiPoint
- [ ] MultiPolygon
- [x] Point
- [ ] Polygon

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
- [ ] smart antimeridian crossing mode? (dual quaternions?)

## architectural decisions

- Features are composed of an N-dimensional arrays of numeric values, e.g (float32). If greater than 2 dimensions are
needed, there is flexibility in that they can represent an elevation (z) and/or other measurement dimensions (m1, m2,
...mn), for example.
- Graphs of geometries within Features are composed of [adjacency
matrices](https://en.wikipedia.org/wiki/Adjacency_matrix) for memory and cache efficiency.
- Promote Mojo's value semantics, because it is preferred over reference semantics.
- Promote vectorization (SIMD) and concurrency.
