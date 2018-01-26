from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.time._date cimport Period
from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/indexes/swap/usdliborswap.hpp' namespace 'QuantLib' nogil:
    cdef cppclass UsdLiborSwapIsdaFixAm(SwapIndex):
        UsdLiborSwapIsdaFixAm(const Period& tenor,
                              const Handle[YieldTermStructure]& h)
                              #= Handle[YieldTermStructure]())
        UsdLiborSwapIsdaFixAm(const Period& tenor,
                              const Handle[YieldTermStructure]& forwarding,
                              const Handle[YieldTermStructure]& discounting)

    cdef cppclass UsdLiborSwapIsdaFixPm(SwapIndex):
        UsdLiborSwapIsdaFixPm(const Period& tenor,
                              const Handle[YieldTermStructure]& h)
                              #= Handle[YieldTermStructure]())
        UsdLiborSwapIsdaFixPm(const Period& tenor,
                              const Handle[YieldTermStructure]& forwarding,
                              const Handle[YieldTermStructure]& discounting)
