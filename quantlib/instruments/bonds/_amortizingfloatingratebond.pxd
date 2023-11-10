from quantlib.types cimport Integer, Natural, Rate, Real, Spread
from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from libcpp.vector cimport vector
from .._bond cimport Bond

cdef extern from "ql/instruments/bonds/amortizingfloatingratebond.hpp" namespace "QuantLib" nogil:
    cdef cppclass AmortizingFloatingRateBond(Bond):
        AmortizingFloatingRateBond(
            Natural settlementDays,
            const vector[Real]& notional,
            const Schedule& schedule,
            const shared_ptr[IborIndex]& index,
            const DayCounter& accrualDayCounter,
            BusinessDayConvention paymentConvention,# = Following,
            Natural fixingDays,# = Null<Natural>(),
            const vector[Real]& gearings, # = { 1.0 },
            const vector[Spread]& spreads, # = { 0.0 },
            const vector[Rate]& caps, # = {},
            const vector[Rate]& floors, # = {},
            bool inArrears,# = false,
            const Date& issueDate,# = Date(),
            const Period& exCouponPeriod,# = Period(),
            const Calendar& exCouponCalendar,# = Calendar(),
            BusinessDayConvention exCouponConvention,# = Unadjusted,
            bool exCouponEndOfMonth, # = false,
            const vector[Real]& redemptions, #= { 100.0 },
            Integer paymentLag # = 0
        ) except +
