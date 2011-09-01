include '../types.pxi'

# cython imports
cimport _option
cimport _payoffs

cdef class Payoff:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'Payoff deallocated'
            del self._thisptr

cdef class PlainVanillaPayoff(Payoff):

    def __init__(self, option_type, float strike):

        self._thisptr = new _payoffs.PlainVanillaPayoff(
            <_option.Type>option_type, <Real>strike
        )
