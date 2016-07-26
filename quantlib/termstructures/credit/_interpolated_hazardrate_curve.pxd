include '../../types.pxi'

from libcpp.vector cimport vector

from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar


cdef extern from 'ql/math/interpolations/all.hpp' namespace 'QuantLib':
    cdef cppclass Linear:
        pass

    cdef cppclass LogLinear:
        pass

    cdef cppclass BackwardFlat:
        pass

cdef extern from 'ql/termstructures/credit/interpolatedhazardratecurve.hpp' namespace 'QuantLib':

    cdef cppclass InterpolatedHazardRateCurve[T](DefaultProbabilityTermStructure):
        InterpolatedHazardRateCurve(const vector[Date]& dates,
                                    const vector[Rate]& hazardRates,
                                    const DayCounter& dayCounter,
                                    const Calendar& cal # = Calendar()
        ) except +
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[Rate]& hazardRates()
        const vector[Date]& dates()
