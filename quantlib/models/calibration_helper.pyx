"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from . cimport _calibration_helper as _ch
from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref

cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.pricingengines.engine cimport PricingEngine


cpdef enum CalibrationErrorType:
    RelativePriceError = _ch.RelativePriceError
    PriceError = _ch.PriceError
    ImpliedVolError = _ch.ImpliedVolError

cdef class CalibrationHelper:

    def __init__(self):
        raise ValueError('Cannot instantiate a CalibrationHelper')

    def set_pricing_engine(self, PricingEngine engine):
        self._thisptr.get().setPricingEngine(deref(engine._thisptr))


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

        return self._thisptr.get().impliedVolatility(targetValue,
                                                     accuracy, maxEvaluations,
                                                     minVol, maxVol)
