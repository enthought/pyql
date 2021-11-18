from quantlib.types cimport Rate, Real, Time
from libcpp.vector cimport vector
from libcpp.pair cimport pair

from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/termstructures/yield/forwardcurve.hpp' namespace 'QuantLib' nogil:

    cdef cppclass InterpolatedForwardCurve[I](YieldTermStructure):
        InterpolatedForwardCurve(const vector[Date]& dates,
                                  vector[Rate]& forwards,
                                  const DayCounter& dayCounter,
                                  const Calendar& cal # = Calendar()
        ) except +
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[Rate]& forwards()
        const vector[Date]& dates()
        vector[pair[Date, Real]]& nodes()
