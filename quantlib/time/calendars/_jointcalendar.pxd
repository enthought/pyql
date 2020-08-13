from libcpp.string cimport string

from quantlib.time._calendar cimport Calendar


cdef extern from 'ql/time/calendars/jointcalendar.hpp' namespace 'QuantLib':

    cdef enum JointCalendarRule:
        JoinHolidays    # A date is a holiday for the joint calendar
                        # if it is a holiday for any of the given calendars
        JoinBusinessDays # A date is a business day for the joint calendar
                         # if it is a business day for any of the given calendars

cdef extern from 'ql/time/calendars/jointcalendar.hpp' namespace 'QuantLib':
    cdef cppclass JointCalendar(Calendar):
            JointCalendar(Calendar& c1,
                          Calendar& c2,
                          JointCalendarRule r) except +
