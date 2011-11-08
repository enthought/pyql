# distutils: language = c++
# distutils: libraries = QuantLib

include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

# cimport quantlib._quote as _qt
from quantlib._quote cimport Quote

cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib':
    cdef cppclass SimpleQuote(Quote):
        SimpleQuote(Real value) except +
        Real setValue(Real value) except +
