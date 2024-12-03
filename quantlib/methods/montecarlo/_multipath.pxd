from quantlib.types cimport Real, Size
from quantlib.math._array cimport Array
from quantlib._time_grid cimport TimeGrid
from libcpp.vector cimport vector
from ._path cimport Path

cdef extern from 'ql/methods/montecarlo/multipath.hpp' namespace 'QuantLib' nogil:
    cdef cppclass MultiPath:
        MultiPath(MultiPath&) # default copy constructor
        MultiPath(Size nAsset, const TimeGrid& timeGrid)
        MultiPath(vector[Path] multiPath)
        Size assetNumber()
        Size pathSize()
        const Path& at(Size j) except +IndexError
        const Path& operator[](Size j)
