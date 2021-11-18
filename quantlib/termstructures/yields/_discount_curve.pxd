include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp.pair cimport pair

from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/termstructures/yield/discountcurve.hpp' namespace 'QuantLib':

    cdef cppclass InterpolatedDiscountCurve[T](YieldTermStructure):
        InterpolatedDiscountCurve(const vector[Date]& dates,
                                  vector[DiscountFactor]& dfs,
                                  const DayCounter& dayCounter,
                                  const Calendar& cal # = Calendar()
        ) except +
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[DiscountFactor]& discounts()
        const vector[Date]& dates()
        vector[pair[Date, Real]]& nodes()
