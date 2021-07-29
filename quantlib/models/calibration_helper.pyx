"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref

cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.pricingengines.engine cimport PricingEngine


cdef class BlackCalibrationHelper:

    def __init__(self):
        raise ValueError('Cannot instantiate a CalibrationHelper')

    cdef inline _ch.BlackCalibrationHelper* as_ptr(self):
        return (<_ch.BlackCalibrationHelper*>self._thisptr.get())

    def set_pricing_engine(self, PricingEngine engine):
        self.as_ptr().setPricingEngine(engine._thisptr)


    def model_value(self):
        return self.as_ptr().modelValue()

    def black_price(self, double volatility):
        return self.as_ptr().blackPrice(volatility)

    def market_value(self):
        return self.as_ptr().marketValue()

    def calibration_error(self):
        return self.as_ptr().calibrationError()

    def impliedVolatility(self, Real targetValue,
                          Real accuracy, Size maxEvaluations,
                          Volatility minVol, Volatility maxVol):

        return self.as_ptr().impliedVolatility(targetValue,
                                                     accuracy, maxEvaluations,
                                                     minVol, maxVol)
