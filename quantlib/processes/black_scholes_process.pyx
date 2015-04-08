from cython.operator cimport dereference as deref
cimport _black_scholes_process as _bsp

from quantlib.handle cimport Handle
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
cimport quantlib.termstructures.volatility.equityfx._black_vol_term_structure as _bvts
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure cimport BlackVolTermStructure


cdef class GeneralizedBlackScholesProcess:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

cdef class BlackScholesProcess(GeneralizedBlackScholesProcess):

    def __init__(self, Quote x0, YieldTermStructure risk_free_ts,
                 BlackVolTermStructure black_vol_ts):

        cdef Handle[_qt.Quote] x0_handle = Handle[_qt.Quote](
            deref(x0._thisptr)
        )
        cdef Handle[_ff.YieldTermStructure] risk_free_ts_handle = \
                deref(risk_free_ts._thisptr.get())

        cdef Handle[_bvts.BlackVolTermStructure] black_vol_ts_handle = \
            Handle[_bvts.BlackVolTermStructure](
                deref(black_vol_ts._thisptr)
            )

        self._thisptr = new shared_ptr[_bsp.GeneralizedBlackScholesProcess]( new \
            _bsp.BlackScholesProcess(
                x0_handle,
                risk_free_ts_handle,
                black_vol_ts_handle
            )
        )

cdef class BlackScholesMertonProcess(GeneralizedBlackScholesProcess):

    def __init__(self,
        Quote x0,
        YieldTermStructure dividend_ts,
        YieldTermStructure risk_free_ts,
        BlackVolTermStructure black_vol_ts):

        cdef Handle[_qt.Quote] x0_handle = Handle[_qt.Quote](
            deref(x0._thisptr)
        )
        cdef Handle[_ff.YieldTermStructure] dividend_ts_handle = \
                deref(dividend_ts._thisptr.get())

        cdef Handle[_ff.YieldTermStructure] risk_free_ts_handle = \
                deref(risk_free_ts._thisptr.get())

        cdef Handle[_bvts.BlackVolTermStructure] black_vol_ts_handle = \
            Handle[_bvts.BlackVolTermStructure](
                deref(black_vol_ts._thisptr)
            )

        self._thisptr = new shared_ptr[_bsp.GeneralizedBlackScholesProcess]( new \
            _bsp.BlackScholesMertonProcess(
                x0_handle,
                dividend_ts_handle,
                risk_free_ts_handle,
                black_vol_ts_handle
            ))
