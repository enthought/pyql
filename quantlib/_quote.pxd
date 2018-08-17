include 'types.pxi'

from libcpp cimport bool
from _observable cimport Observable

cdef extern from 'ql/quote.hpp' namespace 'QuantLib':
    cdef cppclass Quote(Observable):
        Quote()
        Real value() except +
        bool isValid()

cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib':

    cdef cppclass SimpleQuote(Quote):
        SimpleQuote()
        SimpleQuote(Real value)
        Real setValue(Real value)
        void reset()
