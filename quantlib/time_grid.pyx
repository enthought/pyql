include 'types.pxi'
from libcpp.vector cimport vector
from . cimport _time_grid as _tg

cdef class TimeGrid:
    def __init__(self, Time end, Size steps):
        self._thisptr = _tg.TimeGrid(end, steps)

    @classmethod
    def from_vector(cls, vector[Time] l):
        cdef TimeGrid instance = cls.__new__(cls)
        instance._thisptr = _tg.TimeGrid(l.begin(), l.end())
        return instance

    def __len__(self):
        return self._thisptr.size()

    def __iter__(self):
        cdef Size i
        for i in range(self._thisptr.size()):
            yield self._thisptr[i]

    def __getitem__(self, index):
        cdef size_t i
        if isinstance(index, slice):
            return [self._thisptr.at(i)
                    for i in range(*index.indices(len(self)))]
        elif isinstance(index, int):
            return self._thisptr.at(index)
        else:
            raise TypeError('index needs to be an integer or a slice')
