"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from libcpp cimport bool
cimport date
cimport _date
cimport _period
from quantlib.handle cimport shared_ptr


cdef class Period:
    cdef shared_ptr[_period.Period]* _thisptr
    cdef _division(self, object value)

cdef class Date:
    cdef shared_ptr[_date.Date]* _thisptr

cdef date.Date date_from_qldate(const _date.Date& date)
cdef object _pydate_from_qldate(_date.Date qdate)
