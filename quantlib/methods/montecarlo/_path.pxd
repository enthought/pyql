from libcpp cimport bool
from quantlib.types cimport Real, Size
from quantlib.math._array cimport Array
from quantlib._time_grid cimport TimeGrid

cdef extern from 'ql/methods/montecarlo/path.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Path:
        Path(Path&) # default copy constructor
        Path(TimeGrid timeGrid, Array values) #=Array
        bool empty() const
        Size length()
        Real& at(Size i) except +IndexError
        Real& operator[](Size)
        Real& front()
