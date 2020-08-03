include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.termstructures._inflation_term_structure cimport ZeroInflationTermStructure
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Frequency, Period
from quantlib.handle cimport Handle

cdef extern from 'ql/termstructures/inflation/interpolatedzeroinflationcurve.hpp' namespace 'QuantLib':
    cdef cppclass InterpolatedZeroInflationCurve[T](ZeroInflationTermStructure):
        InterpolatedZeroInflationCurve(const Date& referenceDate,
                                       const Calendar& calendar,
                                       const DayCounter& dayCounter,
                                       const Period& lag,
                                       Frequency frequency,
                                       bool indexIsInterpolated,
                                       const vector[Date]& dates,
                                       vector[Rate]& rates) #should be const here
        vector[Date]& dates()
        vector[Real]& data()
        vector[Rate]& rates()
