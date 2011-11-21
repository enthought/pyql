# distutils: language = c++
# distutils: libraries = QuantLib
include '../../types.pxi'

from cython.operator cimport dereference as deref

from libcpp.vector cimport vector

cimport _heston_model as _hm
cimport quantlib.termstructures.yields._flat_forward as _ffwd
cimport quantlib._quote as _qt
cimport quantlib.pricingengines._vanilla as _vanilla
cimport _heston_model as _hm
from quantlib.handle cimport Handle, shared_ptr
from quantlib.math.optimization cimport OptimizationMethod, EndCriteria
from quantlib.processes.heston_process cimport HestonProcess
from quantlib.pricingengines.vanilla cimport AnalyticHestonEngine
from quantlib.quotes cimport Quote
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period
from quantlib.termstructures.yields.flat_forward cimport (
    YieldTermStructure
)

cdef public enum CALIBRATION_ERROR_TYPE:
    RelativePriceError = _hm.RelativePriceError
    PriceError = _hm.PriceError
    ImpliedVolError = _hm.ImpliedVolError

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
        YieldTermStructure dividend_yield,
        error_type=RelativePriceError
    ):
        # create handles
        cdef Handle[_qt.Quote]* volatility_handle = new \
                Handle[_qt.Quote](volatility._thisptr.get())
        cdef Handle[_ffwd.YieldTermStructure]* dividend_yield_handle = new \
            Handle[_ffwd.YieldTermStructure](
                <_ffwd.YieldTermStructure*>(dividend_yield._thisptr.get())
            )
        cdef Handle[_ffwd.YieldTermStructure]* risk_free_rate_handle = new \
            Handle[_ffwd.YieldTermStructure](
               <_ffwd.YieldTermStructure*>(risk_free_rate._thisptr.get())
            )

        self._thisptr = new shared_ptr[_hm.HestonModelHelper](
            new _hm.HestonModelHelper(
                deref(maturity._thisptr.get()),
                deref(calendar._thisptr),
                s0,
                strike_price,
                deref(volatility_handle),
                deref(risk_free_rate_handle),
                deref(dividend_yield_handle),
                <_hm.CalibrationErrorType>error_type
            )
        )

    def set_pricing_engine(self, AnalyticHestonEngine engine):

        cdef shared_ptr[_vanilla.PricingEngine]* pengine = \
            new shared_ptr[_vanilla.PricingEngine](engine._thisptr.get())

        self._thisptr.get().setPricingEngine(
            deref(pengine)
        )

    def model_value(self):
        return self._thisptr.get().modelValue()

    def black_price(self, double volatility):
        return self._thisptr.get().blackPrice(volatility)

    def market_value(self):
        return self._thisptr.get().marketValue()

    def calibration_error(self):
        return self._thisptr.get().calibrationError()

    def impliedVolatility(self, Real targetValue,
        Real accuracy, Size maxEvaluations, 
        Volatility minVol, Volatility maxVol):

        vol = \
        (<_hm.CalibrationHelper *> self._thisptr.get()).impliedVolatility(targetValue, 
        accuracy, maxEvaluations, minVol, maxVol)

        return vol
    
cdef class HestonModel:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass # using a boost::shared_ptr / no need for deallocation

    def __init__(self, HestonProcess process):

        self._thisptr = new shared_ptr[_hm.HestonModel](
            new _hm.HestonModel(deref(process._thisptr))
        )

    property theta:
        def __get__(self):
            return self._thisptr.get().theta()

    property kappa:
        def __get__(self):
            return self._thisptr.get().kappa()

    property sigma:
        def __get__(self):
            return self._thisptr.get().sigma()

    property rho:
        def __get__(self):
            return self._thisptr.get().rho()

    property v0:
        def __get__(self):
            return self._thisptr.get().v0()

    def calibrate(self, helpers, OptimizationMethod method, EndCriteria
            end_criteria):

        #convert list to vector
        cdef vector[shared_ptr[_hm.CalibrationHelper]]* helpers_vector = \
            new vector[shared_ptr[_hm.CalibrationHelper]]()

        cdef shared_ptr[_hm.CalibrationHelper]* chelper
        for helper in helpers:
            chelper = new shared_ptr[_hm.CalibrationHelper](
                (<HestonModelHelper>helper)._thisptr.get()
            )
            helpers_vector.push_back(deref(chelper))

        self._thisptr.get().calibrate(
            deref(helpers_vector),
            deref(method._thisptr.get()),
            deref(end_criteria._thisptr.get())
        )



