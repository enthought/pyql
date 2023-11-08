from .._bond cimport Bond
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.types cimport Natural, Rate, Real, Spread
from quantlib.handle cimport shared_ptr
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time.frequency cimport Frequency
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.dategeneration cimport DateGeneration
from quantlib.time._schedule cimport Schedule
from quantlib.time._daycounter cimport DayCounter
from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from 'ql/instruments/bonds/floatingratebond.hpp' namespace 'QuantLib' nogil:
    cdef cppclass FloatingRateBond(Bond):
        FloatingRateBond(Natural settlementDays,
                         Real faceAmount,
                         Schedule& schedule,
                         const shared_ptr[IborIndex]& iborIndex,
                         DayCounter& accrualDayCounter,
                         BusinessDayConvention paymentConvention,
                         Natural fixingDays, # Null<Natural>()
                         vector[Real]& gearings, # std::vector<Rate>(1, 1.0)
                         vector[Spread]& spreads, #std::vector<Rate>(1, 0.0)
                         vector[Rate]& caps, # std::vector<Rate>()
                         vector[Rate]& floors, # std::vector<Rate>()
                         bool inArrears, # false
                         Real redemption, # 100.
                         Date& issueDate, # Date()
                         const Period& exCouponPeriod, # = Period()
                         const Calendar& exCouponCalendar, # = Calendar()
                         BusinessDayConvention exCouponConvention, # = Unadjusted
                         bool exCouponEndOfMoanth # = false
        ) except +
