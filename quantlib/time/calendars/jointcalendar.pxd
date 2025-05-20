from quantlib.time.calendar cimport Calendar

cdef extern from 'ql/time/calendars/jointcalendar.hpp' namespace 'QuantLib' nogil:

    cpdef enum JointCalendarRule:
        JoinHolidays    # A date is a holiday for the joint calendar
                        # if it is a holiday for any of the given calendars
        JoinBusinessDays # A date is a business day for the joint calendar
                         # if it is a business day for any of the given calendars

cdef class JointCalendar(Calendar):
    pass

