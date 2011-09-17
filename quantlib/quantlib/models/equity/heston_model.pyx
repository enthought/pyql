# distutils: language = c++
# distutils: libraries = QuantLib

include '../../types.pxi'
from cython.operator cimport dereference as deref

cimport _heston_model as _hm
cimport quantlib.termstructures.yields._flat_forward as _ffwd
cimport quantlib.pricingengines._vanilla as _vanilla

from quantlib.handle cimport Handle, shared_ptr
from quantlib.processes.heston_process cimport HestonProcess
from quantlib.pricingengines.vanilla cimport AnalyticHestonEngine
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period
from quantlib.termstructures.yields.flat_forward cimport (
    YieldTermStructure, Quote
)

cdef class HestonModelHelper:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass # using a boost::shared_ptr / no need for deallocation

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

        self._thisptr = new shared_ptr[_hm.HestonModelHelper](
            new _hm.HestonModelHelper(
                deref(maturity._thisptr),
                deref(calendar._thisptr),
                s0,
                strike_price,
                deref(volatility_handle),
                deref(risk_free_rate_handle),
                deref(dividend_yield_handle)
            )
        )

    def set_pricing_engine(self, AnalyticHestonEngine engine):

        cdef shared_ptr[_vanilla.PricingEngine]* pengine = \
            new shared_ptr[_vanilla.PricingEngine](engine._thisptr.get())

        self._thisptr.get().setPricingEngine(
            deref(pengine)
        )



cdef class HestonModel:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass # using a boost::shared_ptr / no need for deallocation

    def __init__(self, HestonProcess process):

        self._thisptr = new shared_ptr[_hm.HestonModel](
            new _hm.HestonModel(deref(process._thisptr))
        )



