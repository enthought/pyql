"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, optional
from .._instrument cimport Instrument
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib._cashflow cimport Leg
from ._swap cimport Swap
from .swap cimport Type
from quantlib.indexes._ibor_index cimport IborIndex

cdef extern from 'ql/instruments/vanillaswap.hpp' namespace 'QuantLib':
    cdef cppclass VanillaSwap(Swap):
        VanillaSwap(Type type,
                    Real nominal,
                    Schedule& fixedSchedule,
                    Rate fixedRate,
                    DayCounter& fixedDayCount,
                    Schedule& floatSchedule,
                    shared_ptr[IborIndex] iborIndex,
                    Spread spread,
                    DayCounter& floatingDayCount,
                    optional[BusinessDayConvention] paymentConvention)

        Type type()
        Real nominal()

        Schedule& fixedSchedule()
        Rate fixedRate()
        DayCounter& fixedDayCount()

        Schedule& floatingSchedule()
        shared_ptr[IborIndex]& iborIndex()
        Spread spread()
        DayCounter& floatingDayCount()

        BusinessDayConvention paymentConvention()

        Leg& fixedLeg()
        Leg& floatingLeg()

        Real fixedLegBPS() except +
        Real fixedLegNPV() except +
        Rate fairRate() except +

        Real floatingLegBPS() except +
        Real floatingLegNPV() except +
        Spread fairSpread() except +
