from quantlib.handle cimport shared_ptr
from . cimport _interest_rate as _ir

cdef class InterestRate:
    cdef _ir.InterestRate _thisptr
