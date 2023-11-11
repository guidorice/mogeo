from python import Python
from benchmark import benchmark
from geo_features.test.constants import lon, lat, height, measure
from utils.vector import DynamicVector
from geo_features import Envelope, Layout4
from random import rand

let num_coords = 1000000


def main():
    bench_envelope_constructor()


fn bench_envelope_constructor() raises:
    var l = Layout4(num_coords)
    l.coordinates = rand[DType.float64](4, num_coords)

    @always_inline
    @parameter
    fn worker_m():
        _ = Envelope(l, num_workers=4)

    @always_inline
    @parameter
    fn worker():
        _ = Envelope(l, num_workers=0)

    print("parallelize")
    let report_m = benchmark.run[worker_m]()
    report_m.print()

    print("serial")
    let report = benchmark.run[worker]()
    report.print()

    let speedup = report.mean() / report_m.mean()
    print(speedup, "X speedup!")
