include '../types.pxi'

from libcpp cimport bool
from libc.stdint cimport int_fast32_t
from _period cimport Period

cdef extern from "ostream" namespace "std":
    cdef cppclass ostream:
        pass

cdef extern from 'ql/time/weekday.hpp' namespace "QuantLib":

    cdef enum Weekday:
        Sunday    = 1
        Monday    = 2
        Tuesday   = 3
        Wednesday = 4
        Thursday  = 5
        Friday    = 6
        Saturday  = 7
        Sun = 1
        Mon = 2
        Tue = 3
        Wed = 4
        Thu = 5
        Fri = 6
        Sat = 7

cdef extern from "ql/time/date.hpp" namespace "QuantLib::Date":
    ctypedef int_fast32_t serial_type
    cdef Date todaysDate()
    cdef Date minDate()
    cdef Date maxDate()
    cdef bool isLeap(Year y)
    cdef Date endOfMonth(Date& d) except +
    cdef bool isEndOfMonth(Date& d)
    cdef Date nextWeekday(Date& d, Weekday w) except +
    cdef Date nthWeekday(Size n, Weekday w,
                         Month m, Year y) except +

cdef extern from "ql/time/date.hpp" namespace "QuantLib":

    cdef enum Month:
        January   = 1
        February  = 2
        March     = 3
        April     = 4
        May       = 5
        June      = 6
        July      = 7
        August    = 8
        September = 9
        October   = 10
        November  = 11
        December  = 12
        Jan = 1
        Feb = 2
        Mar = 3
        Apr = 4
        Jun = 6
        Jul = 7
        Aug = 8
        Sep = 9
        Oct = 10
        Nov = 11
        Dec = 12

    cdef cppclass Date:
        Date() except +
        Date(serial_type serialnumber) except +
        Date(const Date&)
        Date(int d, int m, int y) except +
        Day dayOfMonth() except +
        Month month()
        int year()
        serial_type serialNumber()
        bool operator==(Date*)
        Weekday weekday()
        Day dayOfYear()

        Date& operator++()
        Date& operator++(int value)
        Date& operator--()
        Date& operator--(int value)

        Date operator+(serial_type days)
        Date operator+(Period p)
        Date operator-(serial_type days)
        Date operator-(Period p)

        Date& i_add 'operator+='(serial_type days)
        Date& i_add 'operator+='(Period& period)
        Date& i_sub 'operator-='(Period& period)
        Date& i_sub 'operator-='(serial_type days)
