# MoGeo: Mojo geographic and geometric vector features

[![Run Tests](https://github.com/guidorice/mogeo/actions/workflows/tests.yaml/badge.svg)](https://github.com/guidorice/mogeo/actions/workflows/tests.yaml)

[Mojo🔥](https://github.com/modularml/mojo) package for geographic and geometric
vector features and analytics, such as location data or earth observation data.

## status

| :warning: pre-alpha, not yet usable! |
|--------------------------------------|

If you are interested in contributing or discussing, please first contact me by email or DM on
[Mojo Discord](https://docs.modular.com).

## project goals

- Apply Mojo's systems programming features to create a native geo package with strong
type safety and high performance.
- Promote [cloud native geospatial](https://cloudnativegeo.org/) computing and
open geospatial standards, ex: [GeoParquet](https://geoparquet.org/).
- Leverage the vast Python ecosystem, wherever possible, to enable rapid
development and development and interoperability.

## requirements

- [Mojo](https://github.com/modularml/mojo) >= 0.6
- [Python](https://www.python.org/) >= 3.9
- [Conda](https://docs.conda.io/en/latest/)

## roadmap

### core structs

- [ ] Envelope
- [ ] Feature
- [ ] FeatureCollection
- [ ] GeometryCollection
- [ ] LinearRing
- [ ] LineString
- [ ] Memory Layout
- [ ] MultiLineString
- [ ] MultiPoint
- [ ] MultiPolygon
- [ ] Point
- [ ] Polygon

### serialization and interchange formats

- [ ] GeoArrow
- [ ] GeoJSON
- [ ] GeoParquet
- [ ] TopoJSON
- [ ] WKT

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

## architectural decisions

- Implement a columnar memory layout similar to [GeoArrow](https://geoarrow.org/), for
efficient representation of coordinates, features and attributes.

## related software

- [GEOS](https://libgeos.org/) - Geometry Engine, Open Source.
- [GDAL/OGR](https://gdal.org) - Geospatial Data Abstraction Library.
- [Shapely](https://shapely.readthedocs.io) - Python package for computational geometry.
- [JTS Topology Suite](https://github.com/locationtech/jts) - Java library for creating and manipulating vector geometry.
- [TG](https://github.com/tidwall/tg) - Geometry library for C that is small, fast, and easy to use.
- [Turf.js](https://turfjs.org) - Advanced geospatial analysis for browsers and Node.js.
- [TurfPy](https://turfpy.readthedocs.io/en/latest/) - Python library for performing geospatial data analysis which reimplements turf.js.

## specs

- [ISO/OGC Simple Features](https://en.wikipedia.org/wiki/Simple_Features) - Set of standards that specify a common
  storage and access model of geographic features.
- [GeoJSON](https://geojson.org) - Geospatial data interchange format based on JavaScript Object Notation (JSON).
- [GeoArrow](https://geoarrow.org) - Specification for storing geospatial data in Apache Arrow and Arrow-compatible data
  structures and formats.
- [GeoParquet](https://geoparquet.org) - Specification for storing geospatial vector data (point, line, polygon) in
  Parquet.

## setup dev environment

1. Clone this repo, including submodules:

    ```shell
    git clone --recurse-submodules https://github.com/guidorice/mogeo
    ```

2. Create a Python environment using [environment.yml](./environment.yml). This is required for supporting packages used
by `mogeo`, for example for interchange, serialization, and unit testing.
[Conda](https://docs.conda.io/projects/miniconda/en/latest/) is recommended because it puts a copy of libpython into
each conda env.

    ```text
    conda env create -n mogeo --file environment.yml
    ```

3. Set `MOJO_PYTHON_LIBRARY` environment variable to your libpython. An example of doing
this on MacOS is the [scripts](./scripts/setup-mojo-conda-env-macos.sh)
directory. Help: [Using Mojo with Python](https://www.modular.com/blog/using-mojo-with-python) .

4. Run targets in [Makefile](./Makefile), ex: `make test`, `make package`, `make format`.
