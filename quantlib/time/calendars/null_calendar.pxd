from quantlib.time.calendar cimport Calendar

cdef class NullCalendar(Calendar):
    pass
