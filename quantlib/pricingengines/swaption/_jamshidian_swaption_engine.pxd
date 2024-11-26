from quantlib.handle cimport shared_ptr, Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.pricingengines._pricing_engine cimport PricingEngine
cimport quantlib.models.shortrate._onefactor_model as _ofm


cdef extern from 'ql/pricingengines/swaption/jamshidianswaptionengine.hpp' namespace 'QuantLib' nogil:

    cdef cppclass JamshidianSwaptionEngine(PricingEngine):
        JamshidianSwaptionEngine(
              shared_ptr[_ofm.OneFactorAffineModel]& model,
              Handle[YieldTermStructure]& termStructure)
