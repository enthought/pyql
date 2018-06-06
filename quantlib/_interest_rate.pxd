"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'

from libcpp.string cimport string
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
from quantlib._compounding cimport Compounding

cdef extern from 'ql/interestrate.hpp' namespace 'QuantLib':

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
        InterestRate impliedRate(Real compound,
                                 const DayCounter& resultDC,
                                 Compounding comp,
                                 Frequency freq,
                                 Time t)

        InterestRate equivalentRate(Compounding comp,
                                    Frequency freq,
                                    Time t)
        Real compoundFactor(Time t)

cdef extern from "<sstream>" namespace "std":
    cdef cppclass stringstream:
        stringstream& operator<<(InterestRate&)
        string str()
