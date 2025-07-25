from .._pricing_engine cimport PricingEngine

cdef extrn from 'ql/pricingengines/bond/riskybondengine.hpp' namespace 'QuantLib' nogil:
    cdef cppclass RiskyBondEngine(PricingEngine):
        pass
