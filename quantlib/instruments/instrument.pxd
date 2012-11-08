from quantlib.handle cimport shared_ptr
from quantlib.pricingengines.engine cimport PricingEngine
from libcpp cimport bool as cbool
cimport _instrument

cimport quantlib.pricingengines._pricing_engine as _pe

cdef class Instrument:

    cdef cbool _has_pricing_engine
    cdef shared_ptr[_instrument.Instrument]* _thisptr
