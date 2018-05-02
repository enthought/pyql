from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.time._date cimport Period
from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/indexes/swap/euriborswap.hpp' namespace 'QuantLib' nogil:
    cdef cppclass EuriborSwapIsdaFixA(SwapIndex):
        EuriborSwapIsdaFixA(const Period& tenor,
                            const Handle[YieldTermStructure]& h)
                            #= Handle[YieldTermStructure]())
        EuriborSwapIsdaFixA(const Period& tenor,
                            const Handle[YieldTermStructure]& forwarding,
                            const Handle[YieldTermStructure]& discounting)

    cdef cppclass EuriborSwapIsdaFixB(SwapIndex):
        EuriborSwapIsdaFixB(const Period& tenor,
                            const Handle[YieldTermStructure]& h)
                            #= Handle[YieldTermStructure]())
        EuriborSwapIsdaFixB(const Period& tenor,
                            const Handle[YieldTermStructure]& forwarding,
                            const Handle[YieldTermStructure]& discounting)
