# geo-features

![run tests workflow](https://github.com/github/docs/actions/workflows/tests.yml/badge.svg)

[Mojo🔥](https://github.com/modularml/mojo) package for geographic or geometric
vector features, for example: location data or earth observation data. It is
based upon the [GeoJSON](https://datatracker.ietf.org/doc/html/rfc7946) and
[ISO/OGC Simple Features](https://en.wikipedia.org/wiki/Simple_Features)
standards.

| :warning: pre-alpha, not yet usable! |
|--------------------------------------|

If you are interested in contributing or discussing, please first contact me by email or DM on
[Mojo Discord](https://docs.modular.com).

## requirements

- [Mojo](https://github.com/modularml/mojo) >= 0.5.0
- [Python](https://www.python.org/) >= 3.9
- [Conda](https://docs.conda.io/en/latest/)

## project goals

- Apply Mojo's systems programming features to create a new geo package with strong
type safety and high performance.
- Promote [cloud native geospatial](https://cloudnativegeo.org/) computing and
open geospatial standards, ex: [GeoParquet](https://geoparquet.org/).
- Leverage the vast Python ecosystem, wherever possible, to enable rapid
development and interoperability.

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

## related work

- [GeoArrow](https://geoarrow.org) (C, Python)
- [GEOS](https://libgeos.org/) (C/C++)
- [JTS Topology Suite](https://github.com/locationtech/jts) (Java)
- [Shapely](https://shapely.readthedocs.io) (Python)
- [TG](https://github.com/tidwall/tg) (C)
- [TurfPy](https://turfpy.readthedocs.io/en/latest/) (Python)

## setup dev environment

1. Clone this repo, including submodules:

    ```shell
    git clone --recurse-submodules https://github.com/guidorice/geo-features
    ```

2. Create a Python environment using [environment.yml](./environment.yml). This is required for supporting packages used
by `geo-features`, for example for interchange, serialization, and unit testing.
[Conda](https://docs.conda.io/projects/miniconda/en/latest/) is recommended because it puts a copy of libpython into
each conda env.

    ```text
    conda env create -n geo-features --file environment.yml
    ```

3. Set `MOJO_PYTHON_LIBRARY` environment variable to your libpython. An example of doing
this on MacOS is the [scripts](./scripts/setup-mojo-conda-env-macos.sh)
directory. Help: [Using Mojo with Python](https://www.modular.com/blog/using-mojo-with-python) .

4. Run targets in [Makefile](./Makefile), ex: `make test`, `make package`, `make format`.
