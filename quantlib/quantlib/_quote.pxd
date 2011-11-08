# distutils: language = c++
# distutils: libraries = QuantLib

include 'types.pxi'

from libcpp cimport bool

cdef extern from 'ql/quote.hpp' namespace 'QuantLib':
    cdef cppclass Quote:
        Quote() except +
        Real value() except +
        bool isValid() except +
