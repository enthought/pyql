include '../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle
from _instrument cimport Instrument
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._period cimport Frequency, Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib._cashflow cimport Leg
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.indexes._inflation_index cimport ZeroInflationIndex
from quantlib.time._schedule cimport Rule
from quantlib._compounding cimport Compounding

cdef extern from 'ql/instruments/bond.hpp' namespace 'QuantLib':
    cdef cppclass Bond(Instrument):

        bool isExpired()
        Natural settlementDays()
        Calendar& calendar()
        vector[Real]& notionals()
        Real notional(Date d)
        Leg cashflows()
        Date maturityDate()
        Date issueDate()
        Date settlementDate(Date d)
        bool isTradable(Date d)
        Real accruedAmount(Date d) except +


        Real cleanPrice() except +
        Real dirtyPrice() except +
        Real settlementValue() except +

        Rate clean_yield 'yield'(
                   Real cleanPrice,
                   DayCounter& dc,
                   Compounding comp,
                   Frequency freq,
                   Date settlementDate,
                   Real accuracy,
                   Size maxEvaluations) except +

        Date nextCashFlowDate(Date d) except +
        Date previousCashFlowDate(Date d) except +

cdef extern from 'ql/instruments/bonds/fixedratebond.hpp' namespace 'QuantLib':
    cdef cppclass FixedRateBond(Bond):
        FixedRateBond(Natural settlementDays,
                      Real faceAmount,
                      const Schedule& schedule,
                      vector[Rate]& coupons,
                      DayCounter& accrualDayCounter,
                      BusinessDayConvention paymentConvention,
                      Real redemption, # 100.0
                      const Date& issueDate, # Date()
                      const Calendar& payemntCalendar, # Calendar()
                      const Period& exCouponPeriod, # Period()
                      const Calendar& exCouponCalendar, # Calendar()
                      const BusinessDayConvention exCouponConvention, # Unadjusted,
                      bool exCouponEndOfMonth, # false
                      ) except +

cdef extern from 'ql/instruments/bonds/zerocouponbond.hpp' namespace 'QuantLib':
    cdef cppclass ZeroCouponBond(Bond):
        ZeroCouponBond(Natural settlementDays,
                      Calendar calendar,
                      Real faceAmount,
                      Date maturityDate,
                      BusinessDayConvention paymentConvention,
                      Real redemption,
                      Date& issueDate) except +

cdef extern from 'ql/instruments/bonds/floatingratebond.hpp' namespace 'QuantLib':
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
                         Date& issueDate # Date()
        ) except +
        FloatingRateBond(Natural settlementDays,
                        Real faceAmount,
                        Date& startDate,
                        Date& maturityDate,
                        Frequency couponFrequency,
                        Calendar& calendar,
                        shared_ptr[IborIndex]& iborIndex,
                        DayCounter& accrualDayCounter,
                        BusinessDayConvention accrualConvention,
                        BusinessDayConvention paymentConvention,
                        Natural fixingDays,
                        vector[Real]& gearings,
                        vector[Spread]& spreads,
                        vector[Rate]& caps,
                        vector[Rate]& floors,
                        Real redemption,
                        Date& issueDate,
                        Date& stubDate,
                        Rule rule) except +

cdef extern from 'ql/cashflows/cpicoupon.hpp' namespace 'QuantLib::CPI':
    cdef enum InterpolationType:
        AsIndex
        Flat
        Linear

cdef extern from 'ql/instruments/bonds/cpibond.hpp' namespace 'QuantLib':
    cdef cppclass CPIBond(Bond):
        CPIBond(Natural settlementDays,
                Real faceAmount,
                bool growthOnly,
                Real baseCPI,
                const Period& observationLag,
                shared_ptr[ZeroInflationIndex]& cpiIndex,
                InterpolationType observationInterpolation,
                const Schedule& schedule,
                vector[Rate]& coupons,
                const DayCounter& accrualDayCounter,
                BusinessDayConvention paymentConvention,
                const Date& issueDate, # Date()
                const Calendar& paymentCalendar, #Calendar()
                const Period& exCouponPeriod, # Period()
                const Calendar& exCouponCalendar, # Calendar()
                const BusinessDayConvention exCouponConvention,  # Unadjusted
                bool exCouponEndOfMonth # false
        ) except +
