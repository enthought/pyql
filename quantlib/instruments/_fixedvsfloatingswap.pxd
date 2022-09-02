from libcpp.vector cimport vector

from quantlib.types cimport Natural, Rate, Real, Spread
from quantlib.handle cimport shared_ptr, optional
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib._cashflow cimport Leg
from ._swap cimport Swap
from .swap cimport Type
from quantlib.indexes._ibor_index cimport IborIndex

cdef extern from 'ql/instruments/fixedvsfloatingswap.hpp' namespace 'QuantLib':
    cdef cppclass FixedVsFloatingSwap(Swap):
        FixedVsFloating(Type type,
                        vector[Real] fixed_nominals,
                        Schedule& fixedSchedule,
                        Rate fixedRate,
                        DayCounter& fixedDayCount,
                        vector[Real] floating_nominals,
                        Schedule& floatSchedule,
                        shared_ptr[IborIndex] iborIndex,
                        Spread spread,
                        DayCounter& floatingDayCount,
                        optional[BusinessDayConvention] paymentConvention,
                        Natural payment_lag, # = 0
                        Calendar payment_calendar) # = Calendar()

        Type type()
        Real nominal()
        vector[Real] nominals()

        vector[Real] fixedNominals()
        Schedule& fixedSchedule()
        Rate fixedRate()
        DayCounter& fixedDayCount()

        vector[Real] floatingNominals()
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
