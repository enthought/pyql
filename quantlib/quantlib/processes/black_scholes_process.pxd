from quantlib.handle cimport shared_ptr
cimport _black_scholes_process as _bsp

cdef class GeneralizedBlackScholesProcess:

    cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess]* _thisptr



