include '../types.pxi'

from quantlib.instruments._option cimport Type as OptionType

cdef extern from 'ql/payoff.hpp' namespace 'QuantLib':
        
    cdef cppclass Payoff:
        Payoff()


cdef extern from 'ql/instruments/payoffs.hpp' namespace 'QuantLib':

    cdef cppclass TypePayoff(Payoff):
        TypePayoff()
        TypePayoff(OptionType type)

    cdef cppclass StrikedTypePayoff(TypePayoff):
        StrikedTypePayoff()
        StrikedTypePayoff(OptionType type, Real strike)

    cdef cppclass PlainVanillaPayoff(StrikedTypePayoff):
        PlainVanillaPayoff()
        PlainVanillaPayoff(OptionType type, Real strike)
