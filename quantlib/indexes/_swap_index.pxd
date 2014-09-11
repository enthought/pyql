"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string

from quantlib.handle cimport shared_ptr
from quantlib.indexes._interest_rate_index cimport InterestRateIndex
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib._currency cimport Currency


cdef extern from 'ql/indexes/swapindex.hpp' namespace 'QuantLib':

    cdef cppclass SwapIndex(InterestRateIndex):
        SwapIndex(string& familyName,
                  Period& tenor,
                  Natural settlementDays,
                  Currency currency,
                  Calendar& calendar,
                  Period& fixedLegTenor,
                  BusinessDayConvention fixedLegConvention,
                  DayCounter& fixedLegDayCounter,
                  shared_ptr[IborIndex]& iborIndex)
