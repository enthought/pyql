from quantlib.handle cimport shared_ptr
cimport _payoffs

cdef class Payoff:
    cdef shared_ptr[_payoffs.Payoff]* _thisptr
    cdef set_payoff(self, shared_ptr[_payoffs.Payoff] payoff)

cdef class PlainVanillaPayoff(Payoff):
    pass
