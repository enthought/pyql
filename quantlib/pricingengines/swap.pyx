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
                 includeSettlementDateFlows=None,
                 Date settlementDate=None,
                 Date npvDate=None):

        if includeSettlementDateFlows is None and settlementDate is None and \
           npvDate is None:
            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _swap.DiscountingSwapEngine(discount_curve._thisptr)
            )
        elif includeSettlementDateFlows is not None and \
             settlementDate is not None and \
             npvDate is not None:
            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _swap.DiscountingSwapEngine(
                    discount_curve._thisptr,
                    includeSettlementDateFlows,
                    deref(settlementDate._thisptr.get()),
                    deref(npvDate._thisptr.get())
                )
            )
        else:
            raise NotImplementedError('Constructor not yet implemented')
