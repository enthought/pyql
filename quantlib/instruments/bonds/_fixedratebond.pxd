from quantlib.types cimport Natural, Rate, Real
from libcpp cimport bool
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from libcpp.vector cimport vector
from .._bond cimport Bond

cdef extern from 'ql/instruments/bonds/fixedratebond.hpp' namespace 'QuantLib' nogil:
    cdef cppclass FixedRateBond(Bond):
        FixedRateBond(Natural settlementDays,
                      Real faceAmount,
                      const Schedule& schedule,
                      vector[Rate]& coupons,
                      const DayCounter& accrualDayCounter,
                      BusinessDayConvention paymentConvention,
                      Real redemption, # 100.0
                      const Date& issueDate, # Date()
                      const Calendar& payemntCalendar, # Calendar()
                      const Period& exCouponPeriod, # Period()
                      const Calendar& exCouponCalendar, # Calendar()
                      const BusinessDayConvention exCouponConvention, # Unadjusted,
                      bool exCouponEndOfMonth, # false
                      const DayCounter& firstPeriodDayCounter, # = DayCounter()
                      ) except +
