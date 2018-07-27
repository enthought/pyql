from cython.operator cimport dereference as deref

from libcpp cimport bool
from quantlib.handle cimport shared_ptr, optional
from quantlib.pricingengines.vanilla.vanilla cimport PricingEngine
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cimport quantlib.pricingengines._swap as _swap
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.time.date cimport Date

cdef class DiscountingSwapEngine(PricingEngine):

    def __init__(self, YieldTermStructure discount_curve not None,
                 include_settlement_date_flows=None,
                 Date settlement_date=Date(),
                 Date npv_date=Date()):
        cdef optional[bool] include_settlement_date_flows_opt
        if include_settlement_date_flows is not None:
            include_settlement_date_flows_opt = <bool>include_settlement_date_flows
        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _swap.DiscountingSwapEngine(
                discount_curve._thisptr,
                include_settlement_date_flows_opt,
                deref(settlement_date._thisptr),
                deref(npv_date._thisptr)
            )
        )
