cdef extern from 'ql/pricingengine.hpp' namespace 'QuantLib':

    cdef cppclass PricingEngine:
        PricingEngine()
        PricingEngine(int a)
