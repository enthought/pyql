from libcpp cimport bool
cimport date
cimport _date
cimport _period


cdef class Period:
    cdef _period.Period* _thisptr

cdef class Date:
    cdef _date.Date* _thisptr
    cdef _set_qldate(self, _date.Date& date)

cdef inline date.Date date_from_qldate(_date.Date& date)
cdef inline date.Date date_from_qldate_ref(_date.Date& date)

