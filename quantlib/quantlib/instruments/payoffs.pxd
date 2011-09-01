cimport _payoffs

cdef class Payoff:
    cdef _payoffs.Payoff* _thisptr

cdef class PlainVanillaPayoff(Payoff):
    pass

