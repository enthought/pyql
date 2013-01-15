from quantlib.handle cimport shared_ptr
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.pricingengines.engine cimport PricingEngine

cdef class MCVanillaEngine(PricingEngine):
    pass

