from quantlib.types cimport Rate, Real, Time
from libcpp.vector cimport vector
from libcpp.pair cimport pair

from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

from quantlib.compounding cimport Compounding
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time.frequency cimport Frequency

cdef extern from 'ql/termstructures/yield/zerocurve.hpp' namespace 'QuantLib' nogil:

     cdef cppclass InterpolatedZeroCurve[I](YieldTermStructure):
        InterpolatedZeroCurve(const vector[Date]& dates,
                              vector[Rate]& forwards,
                              const DayCounter& dayCounter,
                              const Calendar& cal, # = Calendar()
                              const I& interpolator,
                              Compounding compounding, # = Continuous,
                              Frequency frequency  # = Annual
        ) except +
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[Rate]& zeroRates()
        const vector[Date]& dates()
        vector[pair[Date, Real]]& nodes()
