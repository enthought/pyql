
from quantlib.handle cimport shared_ptr
cimport _default_term_structure as _dts


cdef class DefaultProbabilityTermStructure: #not inheriting from TermStructure at this point

    cdef shared_ptr[_dts.DefaultProbabilityTermStructure]* _thisptr
