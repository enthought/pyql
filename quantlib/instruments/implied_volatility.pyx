"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from quantlib.instruments.instrument cimport Instrument
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.quotes cimport SimpleQuote

cimport quantlib.instruments._implied_volatility as _iv
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
cimport quantlib.processes._black_scholes_process as _bsp
cimport quantlib._quote as _qt

cdef class ImpliedVolatilityHelper:
    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate an ImpliedVolatilityHelper')

        
    @classmethod
    def calculate(self, Instrument instrument,
              PricingEngine engine,
              SimpleQuote volatility,
              Real target_value,
              Real accuracy,
              Natural max_evaluations,
              Volatility min_vol,
              Volatility max_vol):
    
        return _iv.IVH_calculate(
            deref(instrument._thisptr.get()),
            deref(engine._thisptr.get()),
            deref((<shared_ptr[_qt.SimpleQuote]*> volatility._thisptr).get()),
            target_value,
            accuracy,
            max_evaluations,
            min_vol,
            max_vol)

    # The returned process is equal to the passed one, except
    # for the volatility which is flat and whose value is driven
    # by the passed quote.
            
    @classmethod
    def clone(self,
          GeneralizedBlackScholesProcess process,
          SimpleQuote quote):
    
        cdef shared_ptr[_qt.SimpleQuote]* quote_ptr
        quote_ptr = <shared_ptr[_qt.SimpleQuote]*>(quote._thisptr)

        res = GeneralizedBlackScholesProcess()
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] bsp_ptr

        bsp_ptr = _iv.IVH_clone(deref(process._thisptr),
                          deref(quote_ptr))

        res._thisptr = new shared_ptr[_bsp.GeneralizedBlackScholesProcess]( \
            bsp_ptr)

        return res

