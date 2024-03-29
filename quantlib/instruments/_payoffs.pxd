from quantlib.types cimport Real
from libcpp.string cimport string

from .option cimport OptionType


cdef extern from 'ql/payoff.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Payoff:
        string name()
        string description()
        Real operator()(Real price)

cdef extern from 'ql/instruments/payoffs.hpp' namespace 'QuantLib' nogil:

    cdef cppclass TypePayoff(Payoff):
        TypePayoff(OptionType type)
        OptionType optionType()

    cdef cppclass StrikedTypePayoff(TypePayoff):
        StrikedTypePayoff(OptionType type, Real strike)
        Real strike()

    cdef cppclass PlainVanillaPayoff(StrikedTypePayoff):
        PlainVanillaPayoff(OptionType type, Real strike)

    cdef cppclass PercentageStrikePayoff(StrikedTypePayoff):
        PercentageStrikePayoff(OptionType type, Real moneyness)
