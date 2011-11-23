from libcpp cimport bool
cimport date
cimport _date
cimport _period
from quantlib.handle cimport shared_ptr


cdef class Period:
    cdef shared_ptr[_period.Period]* _thisptr

cdef class Date:
    cdef shared_ptr[_date.Date]* _thisptr

cdef inline date.Date date_from_qldate(_date.Date& date)

