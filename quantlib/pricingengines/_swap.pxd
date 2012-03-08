include '../types.pxi'

from quantlib.handle cimport shared_ptr, Handle
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure

from _pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/swap/discountingswapengine.hpp' namespace 'QuantLib':

    cdef cppclass DiscountingSwapEngine(PricingEngine):
        DiscountingSwapEngine(Handle[YieldTermStructure]& discount_curve)
