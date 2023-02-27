include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from ._period cimport Period
from ._date cimport Date
from ._calendar cimport Calendar, BusinessDayConvention
from quantlib.handle cimport optional
from .dategeneration cimport Rule
cdef extern from 'ql/time/schedule.hpp' namespace 'QuantLib':

    cdef cppclass Schedule:
        Schedule()
        Schedule(Schedule&)
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
        Date& at(Size i) except +IndexError
        Date& operator[](Size i)
        Date previousDate(Date& refDate)
        Date nextDate(Date& refDate)
        vector[Date] dates()
        vector[Date].const_iterator begin()
        vector[Date].const_iterator end()

    Date previousTwentieth(const Date& d, Rule rule)
