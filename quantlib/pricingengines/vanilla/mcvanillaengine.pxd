cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.pricingengines.engine cimport PricingEngine

cdef enum RngTrait:
    PseudoRandom
    LowDiscrepance

cdef enum MCTrait:
    MultiVariate
    SingleVariate

cdef class MCVanillaEngine(PricingEngine):
    pass
