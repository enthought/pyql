"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from quantlib.instruments.instrument cimport Instrument
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.quotes cimport SimpleQuote


cdef class ImpliedVolatilityHelper:
    @classmethod
    def calculate(self,
                  Instrument instrument,
                  PricingEngine engine,
                  SimpleQuote volatility,
                  Real target_value,
                  Real accuracy,
                  Natural max_evaluations,
                  Volatility min_vol,
                  Volatility max_vol):
        return(0)

