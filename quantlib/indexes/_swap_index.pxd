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

from quantlib.currency._currency cimport Currency
from quantlib.handle cimport shared_ptr, Handle
from quantlib.indexes._interest_rate_index cimport InterestRateIndex
from quantlib.indexes._ibor_index cimport IborIndex, OvernightIndex
from quantlib.instruments._vanillaswap cimport VanillaSwap
from quantlib.instruments._overnightindexedswap cimport OvernightIndexedSwap
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.cashflows.rateaveraging cimport RateAveraging

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
                  shared_ptr[IborIndex]& iborIndex) nogil
        SwapIndex(const string& familyName,
                  const Period& tenor,
                  Natural settlementDays,
                  Currency currency,
                  const Calendar& fixingCalendar,
                  const Period& fixedLegTenor,
                  BusinessDayConvention fixedLegConvention,
                  const DayCounter& fixedLegDayCounter,
                  const shared_ptr[IborIndex]& iborIndex,
                  const Handle[YieldTermStructure]& discountingTermStructure) nogil
        shared_ptr[VanillaSwap] underlyingSwap(const Date& fixingDate)
        shared_ptr[IborIndex] iborIndex()
        Handle[YieldTermStructure] forwardingTermStructure() except +
        Handle[YieldTermStructure] discountingTermStructure() except +

    cdef cppclass OvernightIndexedSwapIndex(SwapIndex):
        OvernightIndexedSwapIndex(string& familyName,
                                  Period& tenor,
                                  Natural settlementDays,
                                  Currency currency,
                                  shared_ptr[OvernightIndex]& overnightIndex,
                                  bool telescopic_value_dates, # = False
                                  RateAveraging averaging_method) nogil # = RateAveraing.Compound
        shared_ptr[OvernightIndex] overnight_index()
        shared_ptr[OvernightIndexedSwap] underlying_swap(const Date& fixing_date)
