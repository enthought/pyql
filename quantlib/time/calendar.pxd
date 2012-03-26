cimport _calendar
cimport _date

from libcpp.vector cimport vector

cdef class Calendar:
    cdef _calendar.Calendar* _thisptr

cdef class TARGET(Calendar):
    pass

cdef class UnitedStates(Calendar):
    pass

cdef class UnitedKingdom(Calendar):
    pass

cdef class DateList:
    cdef vector[_date.Date]* _dates
    cdef size_t _pos
    cdef _set_dates(self, vector[_date.Date]& dates)

