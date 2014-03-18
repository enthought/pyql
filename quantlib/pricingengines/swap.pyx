from cython.operator cimport dereference as deref

from libcpp cimport bool
from quantlib.handle cimport shared_ptr, Handle
from quantlib.pricingengines.vanilla.vanilla cimport PricingEngine
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure

cimport quantlib.pricingengines._swap as _swap
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.time.date cimport Date

cdef class DiscountingSwapEngine(PricingEngine):

    def __init__(self, YieldTermStructure discount_curve,
                 bool includeSettlementDateFlows,
                 Date settlementDate,
                 Date npvDate):

        cdef Handle[_yts.YieldTermStructure] yts_handle

        if discount_curve.relinkable:
            yts_handle = Handle[_yts.YieldTermStructure](
                discount_curve._relinkable_ptr.get().currentLink()
            )
        else:
            yts_handle = Handle[_yts.YieldTermStructure](
                discount_curve._thisptr.get()
            )


        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _swap.DiscountingSwapEngine(
                yts_handle,
                includeSettlementDateFlows,
                deref(settlementDate._thisptr.get()),
                deref(npvDate._thisptr.get())
            )
        )

