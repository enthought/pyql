include 'types.pxi'
from libcpp.vector cimport vector

cdef extern from 'ql/timegrid.hpp' namespace 'QuantLib':
    cdef cppclass TimeGrid:
        TimeGrid()
        TimeGrid(Time end, Size steps)
        TimeGrid(vector[Time].iterator begin, vector[Time].iterator end)
        Size size()
        Time at(Size i) except +
        Time operator[](Size i)
