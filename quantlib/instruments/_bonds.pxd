include '../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle
from _instrument cimport Instrument
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._period cimport Frequency
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib._cashflow cimport Leg
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._schedule cimport Rule

# FIXME: this is duplicated everywhere in the code base!!! needs cleanup
cdef extern from 'ql/compounding.hpp' namespace 'QuantLib':
    cdef enum Compounding:
        Simple = 0
        Compounded = 1
        Continuous = 2
        SimpleThenCompounded = 3


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
        Date settlementDate()
        Date settlementDate(Date d)
        bool isTradable(Date d)
        Real accruedAmount() except +
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

        Date nextCachFlowDate(Date d) except +
        Date previousCachFlowDate(Date d) except +

cdef extern from 'ql/instruments/bonds/fixedratebond.hpp' namespace 'QuantLib':
    cdef cppclass FixedRateBond(Bond):
        FixedRateBond(Natural settlementDays,
                      Real faceAmount,
                      Schedule& schedule,
                      vector[Rate]& coupons,
                      DayCounter& accrualDayCounter,
                      BusinessDayConvention paymentConvention,
                      Real redemption) except +
        FixedRateBond(Natural settlementDays,
                      Real faceAmount,
                      Schedule& schedule,
                      vector[Rate]& coupons,
                      DayCounter& accrualDayCounter,
                      BusinessDayConvention paymentConvention,
                      Real redemption,
                      Date& issueDate) except +
        Date settlementDate() except +

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
                        shared_ptr[IborIndex]& iborIndex,
                        DayCounter& accrualDayCounter,
                        BusinessDayConvention paymentConvention,
                        Natural fixingDays, 
                        vector[Real]& gearings,
                        vector[Spread]& spreads,
                        vector[Rate]& caps,
                        vector[Rate]& floors,
                        bool inArrears,
                        Real redemption, 
                        Date& issueDate) except +
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
