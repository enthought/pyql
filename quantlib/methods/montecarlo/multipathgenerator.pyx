from cython.operator cimport dereference as deref
from libcpp cimport bool
from quantlib.stochastic_process cimport StochasticProcess
from quantlib.time_grid cimport TimeGrid
from quantlib.math.randomnumbers.rngtraits cimport PseudoRandom, LowDiscrepancy, FastPseudoRandom
from ._sample cimport Sample
from .multipath cimport MultiPath
from . cimport _multipath as _mp

cdef class PseudoRandomMultiPathGenerator:
    def __init__(self, StochasticProcess process, TimeGrid time_grid, PseudoRandom gen, bool brownian_bridge):
        self._thisptr = new _mpg.MultiPathGenerator[QlPseudoRandom.rsg_type](process._thisptr, time_grid._thisptr, deref(gen._thisptr), brownian_bridge)

    def __next__(self):
        cdef Sample[_mp.MultiPath]* r = <Sample[_mp.MultiPath]*>&self._thisptr.next()
        cdef MultiPath mp = MultiPath.__new__(MultiPath)
        mp._thisptr = new _mp.MultiPath(r.value)
        return (r.weight, mp)

    def __dealloc__(self):
        del self._thisptr



cdef class LowDiscrepancyMultiPathGenerator:
    def __init__(self, StochasticProcess process, TimeGrid time_grid, LowDiscrepancy gen, bool brownian_bridge):
        self._thisptr = new _mpg.MultiPathGenerator[QlLowDiscrepancy.rsg_type](process._thisptr, time_grid._thisptr, deref(gen._thisptr), brownian_bridge)

    def __next__(self):
        cdef Sample[_mp.MultiPath]* r = <Sample[_mp.MultiPath]*>&self._thisptr.next()
        cdef MultiPath mp = MultiPath.__new__(MultiPath)
        mp._thisptr = new _mp.MultiPath(r.value)
        return (r.weight, mp)

    def __dealloc__(self):
        del self._thisptr


cdef class ZigguratMultiPathGenerator:
    def __init__(self, StochasticProcess process, TimeGrid time_grid, FastPseudoRandom gen, bool brownian_bridge):
        self._thisptr = new _mpg.MultiPathGenerator[ZigguratPseudoRandom](process._thisptr, time_grid._thisptr, deref(gen._thisptr), brownian_bridge)

    def __next__(self):
        cdef Sample[_mp.MultiPath]* r = <Sample[_mp.MultiPath]*>&self._thisptr.next()
        cdef MultiPath mp = MultiPath.__new__(MultiPath)
        mp._thisptr = new _mp.MultiPath(r.value)
        return (r.weight, mp)

    def __dealloc__(self):
        del self._thisptr
