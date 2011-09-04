include '../types.pxi'

# cython imports
cimport _option
cimport _payoffs

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option':

    enum Type:
        Put 
        Call 

PayOffTypeInWord = {Call:'Call', Put:'Put'}

cdef class Payoff:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'Payoff deallocated'
            del self._thisptr
    
    def __str__(self):
        return 'Payoff: %s' % self._thisptr.name().c_str()
            
cdef class PlainVanillaPayoff(Payoff):

    def __init__(self, option_type, float strike):

        self._thisptr = new _payoffs.PlainVanillaPayoff(
            <_option.Type>option_type, <Real>strike
        )
        
    def __str__(self):
        return 'Payoff: %s %s @ %f' % (self._thisptr.name().c_str(), 
        PayOffTypeInWord[(<_payoffs.TypePayoff*> self._thisptr).optionType()],
        (<_payoffs.StrikedTypePayoff*> self._thisptr).strike())

        
