include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.termstructures._inflation_term_structure cimport InflationTermStructure
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Frequency, Period
from quantlib.handle cimport Handle

cdef extern from 'ql/math/interpolations/all.hpp' namespace 'QuantLib':
    cdef cppclass Linear:
        pass

    cdef cppclass LogLinear:
        pass

    cdef cppclass BackwardFlat:
        pass


cdef extern from 'ql/termstructures/inflation/interpolatedzeroinflationcurve.hpp' namespace 'QuantLib':
    cdef cppclass InterpolatedZeroInflationCurve[T](InflationTermStructure):
        InterpolatedZeroInflationCurve(const Date& referenceDate,
                                       const Calendar& calendar,
                                       const DayCounter& dayCounter,
                                       const Period& lag,
                                       Frequency frequency,
                                       bool indexIsInterpolated,
                                       const Handle[YieldTermStructure]& yTS,
                                       const vector[Date]& dates,
                                       const vector[Rate]& rates)
