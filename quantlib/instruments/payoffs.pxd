from quantlib.handle cimport shared_ptr
from . cimport _payoffs

cdef class Payoff:
    cdef shared_ptr[_payoffs.Payoff] _thisptr

cdef class StrikedTypePayoff(Payoff):
    pass

cdef class PlainVanillaPayoff(StrikedTypePayoff):
    pass
