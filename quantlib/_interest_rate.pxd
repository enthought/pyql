"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'

from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency

cdef extern from 'ql/compounding.hpp' namespace 'QuantLib':
    cdef enum Compounding:
        pass

cdef extern from 'ql/interestrate.hpp' namespace 'QuantLib':

    cppclass InterestRate:
        InterestRate()
        InterestRate(
            Rate r, DayCounter& dc, Compounding comp, Frequency freq
        ) except+

        Rate rate()
        DayCounter& dayCounter()
        Compounding compounding()
        Frequency frequency()

        DiscountFactor discountFactor(Time t)
