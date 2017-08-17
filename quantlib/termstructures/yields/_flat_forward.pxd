"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, Handle, RelinkableHandle
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
cimport quantlib._quote as _qt
from quantlib._compounding cimport Compounding

from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/termstructures/yield/flatforward.hpp' namespace 'QuantLib':

    cdef cppclass FlatForward(YieldTermStructure):

        FlatForward(DayCounter& dc,
                   vector[Handle[_qt.Quote]]& jumps,
                   vector[Date]& jumpDates,
        ) except +


        FlatForward(Date& referenceDate,
                   Rate forward,
                   DayCounter& dayCounter,
                   Compounding compounding,
                   Frequency frequency
        ) except +

        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Rate forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
                    Frequency frequency
        ) except +

        # from days and quote :
        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Handle[_qt.Quote]& forward,
                    DayCounter& dayCounter,
        ) except +
        
        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Handle[_qt.Quote]& forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
        ) except +
        
        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Handle[_qt.Quote]& forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
                    Frequency frequency
        ) except +
        
        # from date and forward
        FlatForward(Date& referenceDate,
                    Handle[_qt.Quote]& forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
                    Frequency frequency
        ) except +
