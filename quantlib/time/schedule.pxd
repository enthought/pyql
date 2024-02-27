cimport quantlib.time._schedule as _schedule

cdef class Schedule:
    cdef _schedule.Schedule _thisptr
