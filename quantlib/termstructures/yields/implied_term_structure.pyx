from cython.operator import dereference as deref

cimport quantlib.termstructures.yields._implied_term_structure as _its
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date

cdef class ImpliedTermStructure(YieldTermStructure):
    def __init__(self, YieldTermStructure h not None,
                 Date reference_date not None):

        self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
            new _its.ImpliedTermStructure(h._thisptr, reference_date._thisptr)))
