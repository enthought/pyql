from .._payoffs cimport Payoff, StrikedTypePayoff
from ._vanillaoption cimport VanillaOption
from .._exercise cimport Exercise
from quantlib.handle cimport shared_ptr

cdef extern from 'ql/instruments/europeanoption.hpp' namespace 'QuantLib' nogil:

    cdef cppclass EuropeanOption(VanillaOption):
        EuropeanOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )
