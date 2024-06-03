from . cimport _default_term_structure as _dts
from ..termstructure cimport TermStructure
from quantlib.handle cimport RelinkableHandle

cdef class DefaultProbabilityTermStructure(TermStructure):
    cdef _dts.DefaultProbabilityTermStructure* as_dts_ptr(self) noexcept nogil

cdef class HandleDefaultProbabilityTermStructure:
    cdef RelinkableHandle[_dts.DefaultProbabilityTermStructure] handle
