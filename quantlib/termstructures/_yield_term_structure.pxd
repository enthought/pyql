"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, Handle, RelinkableHandle
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date, Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
cimport quantlib._quote as _qt
from quantlib._interest_rate cimport InterestRate
from quantlib._compounding cimport Compounding

cdef extern from 'ql/termstructures/yieldtermstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass YieldTermStructure:
        YieldTermStructure(DayCounter& dc,
                           vector[Handle[_qt.Quote]]& jumps,
                           vector[Date]& jumpDates,
                           ) except +
        DiscountFactor discount(Date& d, bool extrapolate) except +
        DiscountFactor discount(Time t, bool extrapolate) except +
        DayCounter dayCounter()
        Time timeFromReference(Date& d)
        Date referenceDate()
        Date maxDate()
        Time maxTime()
        Calendar calendar()
        int settlementDays()
        InterestRate zeroRate(Date& d,
                              DayCounter& resultDayCounter,
                              Compounding comp,
                              Frequency freq,  # = Annual
                              bool extrapolate  # = False
                              ) except +
        InterestRate zeroRate(Time t,
                              Compounding comp,
                              Frequency freq, # = Annual
                              bool extrapolate
                              ) except +
        InterestRate forwardRate(Date& d1,
                                 Date& d2,
                                 DayCounter& resultDayCounter,
                                 Compounding comp,
                                 Frequency freq,  # = Annual
                                 bool extrapolate  # = False
                             ) except +
        InterestRate forwardRate(Date& d1,
                                 Period& p,
                                 DayCounter& resultDayCounter,
                                 Compounding comp,
                                 Frequency freq,
                                 bool extrapolate,
                                 ... # can't specify the types otherwise cython can't find suitable method
                                 # Date& d1,
                                 # Period& p,
                                 # DayCounter& resultDayCounter,
                                 # Compounding comp,
                                 # Frequency freq, # = Annual
                                 # bool extrapolate # = False
                                 ) except +
        InterestRate forwardRate(Time t1,
                                 Time t2,
                                 Compounding comp,
                                 Frequency freq, # = Annual
                                 bool extrapolate # = False
                                 ) except +

        bool allowsExtrapolation()
        void enableExtrapolation()
        void disableExtrapolation()
