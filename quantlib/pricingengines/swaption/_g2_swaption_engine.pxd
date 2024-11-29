from quantlib.types cimport Real Size
from quantlib.handle cimport shared_ptr
from quantlib.models.shortrate.twofactormodels._g2 cimport G2
from quantlib.pricingengines._pricingengine cimport PricingEngine

cdef extern from 'ql/pricingengines/swaption/g2swaptionengine.hpp' namespace 'QuantLib' nogil:

    cdef cppclass G2SwaptionEngine(PricingEngine):
        G2SwaptionEngine(
            shared_ptr[G2]& model,
            Real range
            Size intervals)
