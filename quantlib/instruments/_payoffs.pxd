include '../types.pxi'
from libcpp.string cimport string

from quantlib.instruments._option cimport Type as OptionType


cdef extern from 'ql/payoff.hpp' namespace 'QuantLib':
        
    cdef cppclass Payoff:
        Payoff()
        string name()
        string description()
        Real operator()(Real price)

cdef extern from 'ql/instruments/payoffs.hpp' namespace 'QuantLib':

    cdef cppclass TypePayoff(Payoff):
        TypePayoff()
        TypePayoff(OptionType type)
        OptionType optionType()

    cdef cppclass StrikedTypePayoff(TypePayoff):
        StrikedTypePayoff()
        StrikedTypePayoff(OptionType type, Real strike)
        Real strike()

    cdef cppclass PlainVanillaPayoff(StrikedTypePayoff):
        PlainVanillaPayoff()
        PlainVanillaPayoff(OptionType type, Real strike)
