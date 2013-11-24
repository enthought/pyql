from quantlib.handle cimport shared_ptr
cimport _interest_rate as _ir

cdef class InterestRate:
    cdef shared_ptr[_ir.InterestRate]* _thisptr

