"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._daycounter cimport DayCounter
from quantlib.quote cimport SimpleQuote
from quantlib.instruments.instrument cimport Instrument

cimport quantlib._quote as _qt
cimport quantlib.processes._black_scholes_process as _bs

cdef extern from 'ql/instruments/impliedvolatility.hpp' namespace 'QuantLib::detail':

    cdef cppclass ImpliedVolatilityHelper:
        @staticmethod
        Volatility calculate(Instrument& instrument,
                             PricingEngine& engine,
                             SimpleQuote& volQuote,
                             Real targetValue,
                             Real accuracy,
                             Natural maxEvaluations,
                             Volatility minVol,
                             Volatility maxVol) except +

        # The returned process is equal to the passed one, except
        # for the volatility which is flat and whose value is driven
        # by the passed quote.
            
        @staticmethod
        shared_ptr[GeneralizedBlackScholesProcess] clone(
                     shared_ptr[_bs.GeneralizedBlackScholesProcess]& process,
                     shared_ptr[_qt.SimpleQuote]& quote)
