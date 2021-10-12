from quantlib.types cimport Real
from libcpp cimport bool
from ._observable cimport Observable

cdef extern from 'ql/quote.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Quote(Observable):
        Quote()
        Real value() except +
        bool isValid()
