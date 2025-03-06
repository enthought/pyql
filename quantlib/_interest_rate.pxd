"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from quantlib.types cimport DiscountFactor, Rate, Real, Time
from libcpp.string cimport string
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
from quantlib.compounding cimport Compounding

cdef extern from 'ql/interestrate.hpp' namespace 'QuantLib' nogil:

    cppclass InterestRate:
        InterestRate()
        InterestRate(InterestRate&)
        InterestRate(
            Rate r, DayCounter& dc, Compounding comp, Frequency freq
        ) except+

        Rate rate()
        DayCounter& dayCounter()
        Compounding compounding()
        Frequency frequency()

        DiscountFactor discountFactor(Time t)
        DiscountFactor discountFactor(const Date& d1,
                                      const Date &d2,
                                      const Date& refStart,
                                      const Date& refEnd)
        InterestRate impliedRate(Real compound,
                                 const DayCounter& resultDC,
                                 Compounding comp,
                                 Frequency freq,
                                 Time t)

        InterestRate equivalentRate(Compounding comp,
                                    Frequency freq,
                                    Time t)
        Real compoundFactor(Time t)
        Real compoundFactor(const Date& d1,
                            const Date &d2,
                            const Date& refStart,
                            const Date& refEnd)

cdef extern from "<sstream>" namespace "std":
    cdef cppclass stringstream:
        stringstream& operator<<(InterestRate&)
        string str()
