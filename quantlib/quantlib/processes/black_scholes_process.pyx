from cython.operator cimport dereference as deref
cimport _black_scholes_process as _bsp

from quantlib.handle cimport Handle
cimport quantlib.termstructures.yields._flat_forward as _ff
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure, Quote
cimport quantlib.termstructures.volatility.equityfx._black_vol_term_structure as _bvts
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure cimport BlackVolTermStructure


cdef class GeneralizedBlackScholesProcess:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr



cdef class BlackScholesMertonProcess(GeneralizedBlackScholesProcess):

    def __init__(self,
        Quote x0,
        YieldTermStructure dividend_ts,
        YieldTermStructure risk_free_ts,
        BlackVolTermStructure black_vol_ts,
    ):

        #create handles

        cdef Handle[_ff.Quote]* x0_handle = new Handle[_ff.Quote](
            x0._thisptr.get()
        )
        cdef Handle[_ff.YieldTermStructure]* dividend_ts_handle = new \
                Handle[_ff.YieldTermStructure](dividend_ts._thisptr)
        cdef Handle[_ff.YieldTermStructure]* risk_free_ts_handle = new \
                Handle[_ff.YieldTermStructure](risk_free_ts._thisptr)
        cdef Handle[_bvts.BlackVolTermStructure]* black_vol_ts_handle = new \
                Handle[_bvts.BlackVolTermStructure](black_vol_ts._thisptr)

        self._thisptr = new _bsp.BlackScholesMertonProcess(
            deref(x0_handle),
            deref(dividend_ts_handle),
            deref(risk_free_ts_handle),
            deref(black_vol_ts_handle)
        )
