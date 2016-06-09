include 'types.pxi'

from libcpp cimport bool

cdef extern from 'ql/quote.hpp' namespace 'QuantLib':
    cdef cppclass Quote:
        Quote()
        Real value() except +
        bool isValid()

cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib':

    cdef cppclass SimpleQuote(Quote):
        SimpleQuote()
        SimpleQuote(Real value)
        Real setValue(Real value)
        void reset()
