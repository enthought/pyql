
include '../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from _pricing_engine cimport PricingEngine
cimport quantlib.models.shortrate._onefactor_model as _ofm


cdef extern from 'ql/pricingengines/swaption/jamshidianswaptionengine.hpp' namespace 'QuantLib':

    cdef cppclass JamshidianSwaptionEngine(PricingEngine):
        JamshidianSwaptionEngine()
        JamshidianSwaptionEngine(
              shared_ptr[_ofm.OneFactorAffineModel]& model,
              Handle[YieldTermStructure]& termStructure)
