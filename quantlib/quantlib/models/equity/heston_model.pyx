# distutils: language = c++
# distutils: libraries = QuantLib

include '../../types.pxi'
from cython.operator cimport dereference as deref

cimport _heston_model as _hm

cimport quantlib.termstructures.yields._flat_forward as _ffwd
from quantlib.handle cimport Handle
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period
from quantlib.termstructures.yields.flat_forward cimport (
    YieldTermStructure, Quote
)

cdef class HestonModelHelper:

    cdef _hm.HestonModelHelper* _thisptr

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __init__(self,
        Period maturity,
        Calendar calendar,
        Real s0,
        Real strike_price,
        Quote volatility,
        YieldTermStructure risk_free_rate,
        YieldTermStructure dividend_yield
    ):
        # create handles
        cdef Handle[_ffwd.Quote]* volatility_handle = new \
                Handle[_ffwd.Quote](volatility._thisptr)
        cdef Handle[_ffwd.YieldTermStructure]* dividend_yield_handle = new \
            Handle[_ffwd.YieldTermStructure](dividend_yield._thisptr)
        cdef Handle[_ffwd.YieldTermStructure]* risk_free_rate_handle = new \
            Handle[_ffwd.YieldTermStructure](risk_free_rate._thisptr)        

        self._thisptr = new _hm.HestonModelHelper(
            deref(maturity._thisptr),
            deref(calendar._thisptr),
            s0,
            strike_price,
            deref(volatility_handle),
            deref(risk_free_rate_handle),
            deref(dividend_yield_handle)
        )

