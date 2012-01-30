from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr, Handle
from quantlib.pricingengines.vanilla cimport PricingEngine
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure

cimport quantlib.pricingengines._swap as _swap
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.termstructures.yields._flat_forward as _ff

cdef class DiscountingSwapEngine(PricingEngine):

    def __init__(self, YieldTermStructure ts):

        cdef Handle[_ff.YieldTermStructure] handle = \
            Handle[_ff.YieldTermStructure](deref(ts._thisptr))

        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _swap.DiscountingSwapEngine(
                handle
            )
        )

