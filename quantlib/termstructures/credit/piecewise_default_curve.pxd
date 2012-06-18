from quantlib.handle cimport shared_ptr
from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure

cdef class PiecewiseDefaultCurve:

    cdef shared_ptr[DefaultProbabilityTermStructure]* _thisptr

