
from quantlib.types cimport Integer, Natural, Rate, Real, Spread
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

from ._fixedvsfloatingswap cimport FixedVsFloatingSwap
from .swap cimport Type

cdef extern from 'ql/instruments/overnightindexedswap.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexedSwap(FixedVsFloatingSwap):
        OvernightIndexedSwap(Type type,
                             Real nominal,
                             const Schedule& fixedSchedule,
                             Rate fixedRate,
                             DayCounter fixedDC,
                             const Schedule overnightSchedule,
                             shared_ptr[OvernightIndex] overnightIndex,
                             Spread spread, # = 0.0,
                             Integer paymentLag, # = 0,
                             BusinessDayConvention paymentAdjustment, # = Following,
                             const Calendar& paymentCalendar, # = Calendar(),
                             bool telescopicValueDates, # = false,
                             RateAveraging averagingMethod, # = RateAveraging::Compound);
                             Natural lookbackDays, # = Null<Natural>(),
                             Natural lockoutDays, # = 0,
                             bool applyObservationShift) # = False

        OvernightIndexedSwap(Type type,
                             vector[Real] fixed_nominals,
                             const Schedule& fixedSchedule,
                             Rate fixedRate,
                             DayCounter fixedDC,
                             vector[Real] overnight_nominals,
                             const Schedule overnightSchedule,
                             shared_ptr[OvernightIndex] overnightIndex,
                             Spread spread, # = 0.0,
                             Integer paymentLag, # = 0,
                             BusinessDayConvention paymentAdjustment, # = Following,
                             const Calendar& paymentCalendar, # = Calendar(),
                             bool telescopicValueDates, # = false,
                             RateAveraging averagingMethod, # = RateAveraging::Compound);
                             Natural lookbackDays, # = Null<Natural>(),
                             Natural lockoutDays, # = 0,
                             bool applyObservationShift) # = False
        Frequency paymentFrequency()

        const shared_ptr[OvernightIndex]& overnightIndex()
        const Leg& overnightLeg() const

        RateAveraging averagingMethod() const
        Natural lookbackDays() const
        Natural lockoutDays() const
        bool applyObservationShift() const

        Real overnightLegBPS() const
        Real overnightLegNPV() const
