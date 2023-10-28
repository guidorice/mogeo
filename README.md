# geo-features

`geo-features` is a [Mojo🔥](https://github.com/modularml/mojo) package for
geographic or geometric vector features, for example: location data or earth
observation data. It is based upon the
[GeoJSON](https://datatracker.ietf.org/doc/html/rfc7946) and [ISO/OGC Simple
Features](https://en.wikipedia.org/wiki/Simple_Features) standards.

| :warning: pre-alpha, not yet usable! |
|--------------------------------------|

If you are interested in contributing or discussing, please first contact me by email or DM on
[Mojo Discord](https://docs.modular.com).

## requirements

- [Mojo](https://github.com/modularml/mojo) >= 0.4.0
- [Python](https://www.python.org/) >= 3.9
- [Poetry](https://python-poetry.org/) >= 1.6

## project goals

- Apply Mojo's systems programming features to create a new geo package with strong
type safety and high performance.
- Promote [cloud native geospatial](https://cloudnativegeo.org/) computing and
open geospatial standards, ex: [GeoParquet](https://geoparquet.org/).
- Leverage the vast Python ecosystem, wherever possible, to enable rapid
development and interoperability.

## roadmap

### structs

- [x] Envelope (wip)
- [ ] Feature
- [ ] FeatureCollection
- [x] Layout (wip) - GeoArrow-ish
- [ ] GeometryCollection
- [ ] LinearRing
- [ ] MultiLineString
- [x] MultiPoint
- [ ] MultiPolygon
- [ ] Polygon
- [x] LineString (wip)
- [x] Point

### serialization formats

- [x] WKT (wip)
- [x] GeoJSON (wip)
- [ ] GeoArrow
- [ ] GeoParquet
- [ ] TopoJSON

### methods and algorithms

- [ ] area
- [ ] perimeter
- [ ] centroid
- [ ] intersection
- [ ] union
- [ ] difference
- [ ] parallelized+vectorized spatial join
- [ ] rasterize from vector
- [ ] vectorize from raster
- [ ] re-projection and CRS support
- [ ] simplify or decimate
- [ ] stratified sampling?
- [ ] zonal stats?
- [ ] smart antimeridian crossing mode (quaternions?)

## related work

- [GeoArrow](https://geoarrow.org) (C, Rust, Python)
- [GEOS](https://libgeos.org/) (C/C++)
- [JTS Topology Suite](https://github.com/locationtech/jts) (Java)
- [Shapely](https://shapely.readthedocs.io) (Python)
- [TG](https://github.com/tidwall/tg) (C)
- [TurfPy](https://turfpy.readthedocs.io/en/latest/) (Python)
- plus many more!
