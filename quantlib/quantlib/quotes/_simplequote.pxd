# distutils: language = c++
# distutils: libraries = QuantLib

include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

cimport quantlib._quote as _qt

cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib':
    cdef cppclass SimpleQuote(_qt.Quote):
        SimpleQuote(Real value) except +
        Real setValue(Real value) except +
