include '../types.pxi'

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

from ._date cimport Date, Weekday
from ._period cimport Period, TimeUnit
from .businessdayconvention cimport BusinessDayConvention

cdef extern from 'ql/time/calendar.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Calendar:
            Calendar()
            Calendar(Calendar&)
            string name()
            bool empty()
            bool isHoliday(Date& d)
            bool isBusinessDay(Date& d)
            bool isWeekend(Weekday wd)
            bool isEndOfMonth(Date& d)
            void addHoliday(Date& d)
            void removeHoliday(Date& d)
            long businessDaysBetween(Date& d1, Date& d2, bool includeFirst,
                    bool includeLast)
            Date endOfMonth(Date& d)
            Date adjust(Date&, BusinessDayConvention convention)
            Date advance(Date&, Integer n, TimeUnit unit, BusinessDayConvention convention, bool endOfMonth)
            Date advance(Date& date, Period& period, BusinessDayConvention convention, bool endOfMonth)
            bool operator==(Calendar&)
            bool operator!=(Calendar&)

            vector[Date] holidayList(const Date& from_date, const Date& to_date, int includeWeekEnds)
            vector[Date] businessDayList(const Date& from_date,
                                         const Date& to)
