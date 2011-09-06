include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _heston_process as _hp

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure, Quote

cdef class HestonProcess:

    cdef shared_ptr[_hp.HestonProcess]* _thisptr

    def __cinit__(self):
        pass

    def __dealloc(self):
        pass

    def __init__(self,
       YieldTermStructure risk_free_rate_ts,
       YieldTermStructure dividend_ts,
       Quote s0,
       Real v0,
       Real kappa,
       Real theta,
       Real sigma,
       Real rho
    ):

        #create handles
        cdef Handle[_ff.Quote]* s0_handle = new Handle[_ff.Quote](s0._thisptr)
        cdef Handle[_ff.YieldTermStructure]* dividend_ts_handle = new \
                Handle[_ff.YieldTermStructure](dividend_ts._thisptr)
        cdef Handle[_ff.YieldTermStructure]* risk_free_rate_ts_handle = new \
                Handle[_ff.YieldTermStructure](risk_free_rate_ts._thisptr)

        self._thisptr = new shared_ptr[_hp.HestonProcess](new 
            _hp.HestonProcess(
                deref(risk_free_rate_ts_handle),
                deref(dividend_ts_handle),
                deref(s0_handle),
                v0, kappa, theta, sigma, rho
            )
        )

