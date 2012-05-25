"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle, RelinkableHandle
from quantlib._quote cimport Quote
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period, Frequency
from _flat_forward cimport YieldTermStructure
from quantlib.indexes._ibor_index cimport IborIndex

cimport quantlib.indexes._ibor_index as _ib

from quantlib.termstructures._helpers cimport BootstrapHelper, RelativeDateBootstrapHelper

cdef extern from 'ql/termstructures/yield/ratehelpers.hpp' namespace 'QuantLib':

    ctypedef BootstrapHelper[YieldTermStructure] RateHelper

    cdef cppclass RelativeDateRateHelper:
        Handle[Quote] quote()

    cdef cppclass DepositRateHelper(RateHelper):
        DepositRateHelper(Handle[Quote]& rate,
                          Period& tenor,
                          Natural fixingDays,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter)
        DepositRateHelper(Rate rate,
                          Period& tenor,
                          Natural fixingDays,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter)

        # Not supporting IborIndex at this stage
        DepositRateHelper(Handle[Quote]& rate,
                          shared_ptr[IborIndex]& iborIndex)
        DepositRateHelper(Rate rate,
                          shared_ptr[IborIndex]& iborIndex)

    cdef cppclass FraRateHelper(RelativeDateRateHelper):
        FraRateHelper(Handle[Quote]& rate,
                      Natural monthsToStart,
                      Natural monthsToEnd,
                      Natural fixingDays,
                      Calendar& calendar,
                      BusinessDayConvention convention,
                      bool endOfMonth,
                      DayCounter& dayCounter)


    cdef cppclass SwapRateHelper(RelativeDateRateHelper):
        SwapRateHelper(Handle[Quote]& rate,
                          Period& tenor,
                          Calendar& calendar,
                          Frequency& fixedFrequency,
                          BusinessDayConvention fixedConvention,
                          DayCounter& fixedDayCount,
                          shared_ptr[_ib.IborIndex]& iborIndex,
                          Handle[Quote]& spread,
                          Period& fwdStart)

    cdef cppclass FuturesRateHelper(RateHelper):
        FuturesRateHelper(Handle[Quote]& price,
                          Date& immDate,
                          Natural lengthInMonths,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter) except +

