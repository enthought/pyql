from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/nullcalendar.hpp' namespace 'QuantLib':
    cdef cppclass NullCalendar(Calendar):
        NullCalendar()

