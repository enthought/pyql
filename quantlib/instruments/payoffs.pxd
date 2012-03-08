from quantlib.handle cimport shared_ptr
cimport _payoffs

cdef class Payoff:
    cdef shared_ptr[_payoffs.Payoff]* _thisptr

cdef class PlainVanillaPayoff:
    cdef shared_ptr[_payoffs.StrikedTypePayoff]* _thisptr

