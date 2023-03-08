from quantlib.types cimport Natural, Rate, Real, Spread
from quantlib.cashflows.rateaveraging cimport RateAveraging
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib._cashflow cimport Leg
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._schedule cimport Schedule
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._ibor_index cimport OvernightIndex
from quantlib.time._period cimport Frequency

from ._swap cimport Swap
from .swap cimport Type

cdef extern from 'ql/instruments/overnightindexedswap.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexedSwap(Swap):
        OvernightIndexedSwap(Type type,
                             Real nominal,
                             const Schedule& schedule,
                             Rate fixedRate,
                             DayCounter fixedDC,
                             shared_ptr[OvernightIndex] overnightIndex,
                             Spread spread, # = 0.0,
                             Natural paymentLag, # = 0,
                             BusinessDayConvention paymentAdjustment, # = Following,
                             const Calendar& paymentCalendar, # = Calendar(),
                             bool telescopicValueDates, # = false,
                             RateAveraging averagingMethod) # = RateAveraging::Compound);

        OvernightIndexedSwap(Type type,
                             vector[Real] nominals,
                             const Schedule& schedule,
                             Rate fixedRate,
                             DayCounter fixedDC,
                             shared_ptr[OvernightIndex] overnightIndex,
                             Spread spread, # = 0.0,
                             Natural paymentLag, # = 0,
                             BusinessDayConvention paymentAdjustment, # = Following,
                             const Calendar& paymentCalendar, # = Calendar(),
                             bool telescopicValueDates, # = false,
                             RateAveraging averagingMethod) # = RateAveraging::Compound);

        Type type() const
        Real nominal() const
        vector[Real] nominals() const

        Frequency paymentFrequency()

        Rate fixedRate() const
        const DayCounter& fixedDayCount()

        const shared_ptr[OvernightIndex]& overnightIndex()
        Spread spread() const

        const Leg& fixedLeg() const
        const Leg& overnightLeg() const

        RateAveraging averagingMethod() const
        Real fixedLegBPS() const
        Real fixedLegNPV() const
        Real fairRate() const

        Real overnightLegBPS() const
        Real overnightLegNPV() const
        Spread fairSpread() const
