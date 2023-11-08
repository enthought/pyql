from libcpp.vector cimport vector
from quantlib.handle cimport Handle
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time.frequency cimport Frequency

from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib._quote cimport Quote
from quantlib.math._interpolations cimport Linear
from quantlib.compounding cimport Compounding

cdef extern from 'ql/termstructures/yield/piecewisezerospreadedtermstructure.hpp' namespace 'QuantLib':
    cdef cppclass InterpolatedPiecewiseZeroSpreadedTermStructure[I](YieldTermStructure):
        InterpolatedPiecewiseZeroSpreadedTermStructure(
            const Handle[YieldTermStructure]&,
            const vector[Handle[Quote]]& spreads,
            const vector[Date]& dates,
            Compounding comp, # = Continuous,
            Frequency freq, # = NoFrequency,
            const DayCounter& dc), # = DayCounter(),
            #const Interpolator& factory) # = Interpolator())
    ctypedef InterpolatedPiecewiseZeroSpreadedTermStructure[Linear] PiecewiseZeroSpreadedTermStructure
