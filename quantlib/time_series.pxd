include 'types.pxi'

cimport quantlib._time_series as _ts

cdef class TimeSeries:
    cdef _ts.TimeSeries[Real] _thisptr
