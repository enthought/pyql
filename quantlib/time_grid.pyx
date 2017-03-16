include 'types.pxi'
from libcpp.vector cimport vector
cimport _time_grid as _tg

cdef class TimeGrid:
    def __cinit__(self, Time end, Size steps):
        self._thisptr = _tg.TimeGrid(end, steps)

    @classmethod
    def from_vector(cls, vector[Time] l):
        cdef TimeGrid instance = cls.__new__(cls)
        instance._thisptr = _tg.TimeGrid(l.begin(), l.end())
        return instance
