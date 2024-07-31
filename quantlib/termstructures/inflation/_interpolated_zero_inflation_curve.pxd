include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.termstructures._inflation_term_structure cimport ZeroInflationTermStructure
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Frequency, Period
from quantlib.handle cimport Handle, shared_ptr
from ._seasonality cimport Seasonality

cdef extern from 'ql/termstructures/inflation/interpolatedzeroinflationcurve.hpp' namespace 'QuantLib' nogil:
    cdef cppclass InterpolatedZeroInflationCurve[T](ZeroInflationTermStructure):
        InterpolatedZeroInflationCurve(const Date& referenceDate,
                                       vector[Date]& dates,
                                       vector[Rate]& rates,
                                       Frequency frequency,
                                       DayCounter dayCounter,
                                       shared_ptr[Seasonality] seasonality)
        vector[Date]& dates()
        vector[Real]& data()
        vector[Rate]& rates()
