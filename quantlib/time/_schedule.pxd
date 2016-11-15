include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from _period cimport Period
from _date cimport Date
from _calendar cimport Calendar, BusinessDayConvention

cdef extern from 'boost/optional.hpp' namespace 'boost':
    cdef cppclass optional[T]:
        optional(T)
        optional(T*)

    cdef int none

cdef extern from 'ql/time/dategenerationrule.hpp' namespace \
        'QuantLib::DateGeneration':

    cdef enum Rule:
        Backward # Backward from termination date to effective date.
        Forward  # Forward from effective date to termination date.
        Zero     # No intermediate dates between effective date
                 # and termination date.
        ThirdWednesday # All dates but effective date and termination
                       # date are taken to be on the third wednesday
                       # of their month (with forward calculation.)
        Twentieth # All dates but the effective date are taken to be the 
                  # twentieth of their month (used for CDS schedules in
                  # emerging markets.)  The termination date is also modified.
        TwentiethIMM # All dates but the effective date are taken to be the 
                     # twentieth of an IMM month (used for CDS schedules.)  The
                     # termination date is also modified.
        OldCDS # Same as TwentiethIMM with unrestricted date ends and log/short
               # stub coupon period (old CDS convention).
        CDS # Credit derivatives standard rule since 'Big Bang' changes in 2009.
 
cdef extern from 'ql/time/schedule.hpp' namespace 'QuantLib':

    cdef cppclass Schedule:
        Schedule()
        Schedule(Date& effectiveDate,
                 Date& terminationDate,
                 Period& tenor,
                 Calendar& calendar,
                 BusinessDayConvention convention,
                 BusinessDayConvention terminationDateConvention,
                 Rule rule,
                 bool endOfMonth,
        ) except +
        Schedule(Date& effectiveDate,
                 Date& terminationDate,
                 Period& tenor,
                 Calendar& calendar,
                 BusinessDayConvention convention,
                 BusinessDayConvention terminationDateConvention,
                 Rule rule,
                 bool endOfMonth,
                 Date& firstDate,
                 Date& nextToLastDate
        ) except +
        Schedule(vector[Date]& dates,
                 Calendar& calendar,
                 BusinessDayConvention convention,
                 optional[BusinessDayConvention] terminationDateConvention,
                 optional[Period] tenor,
                 optional[Rule] rule,
                 optional[bool] endOfMonth,
                 vector[bool]& isRegular
        ) except +

        Size size()
        Date& at(Size i)
        Date previousDate(Date& refDate)
        Date nextDate(Date& refDate)
        vector[Date] dates()
