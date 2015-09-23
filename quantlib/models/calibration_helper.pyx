"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _calibration_helper as _ch
from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref

cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.pricingengines.engine cimport PricingEngine


cdef public enum CalibrationErrorType:
    RelativePriceError = _ch.RelativePriceError
    PriceError = _ch.PriceError
    ImpliedVolError = _ch.ImpliedVolError
    
cdef class CalibrationHelper:

    def __cinit__(self):
        pass

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __init__(self):
        raise ValueError('Cannot instantiate a CalibrationHelper')

    def set_pricing_engine(self, PricingEngine engine):
        cdef shared_ptr[_pe.PricingEngine] pengine = \
            shared_ptr[_pe.PricingEngine](<shared_ptr[_pe.PricingEngine] &>deref(engine._thisptr))

        self._thisptr.get().setPricingEngine(pengine)


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
        (<_ch.CalibrationHelper *> self._thisptr.get()).impliedVolatility(targetValue,
        accuracy, maxEvaluations, minVol, maxVol)

        return vol

