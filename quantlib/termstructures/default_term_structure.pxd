from quantlib.handle cimport shared_ptr
from . cimport _default_term_structure as _dts
from quantlib.observable cimport Observable

cdef class DefaultProbabilityTermStructure(Observable):
    cdef shared_ptr[_dts.DefaultProbabilityTermStructure] _thisptr
