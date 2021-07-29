from quantlib.handle cimport shared_ptr
cimport quantlib.pricingengines._pricing_engine as _pe

cdef class PricingEngine:
    cdef shared_ptr[_pe.PricingEngine] _thisptr


