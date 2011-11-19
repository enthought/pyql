cimport _flat_forward as ffwd
from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr

from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure

cdef class FlatForward(YieldTermStructure):
    pass


