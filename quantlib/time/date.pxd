# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.


from libcpp cimport bool
from ._date cimport Date as QlDate

cimport quantlib.time._period as _period
from quantlib.handle cimport shared_ptr

cdef extern from 'ql/time/weekday.hpp' namespace "QuantLib" nogil:

    cpdef enum Weekday:
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

cdef extern from "ql/time/date.hpp" namespace "QuantLib" nogil:

    cpdef enum Month:
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


cdef class Period:
    cdef shared_ptr[_period.Period] _thisptr

cdef class Date:
    cdef QlDate _thisptr

cdef Date date_from_qldate(const QlDate& date)
cdef Period period_from_qlperiod(const _period.Period& period)

cdef object _pydate_from_qldate(QlDate qdate)
cdef QlDate _qldate_from_pydate(object date)
