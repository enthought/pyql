from quantlib.handle cimport Handle, shared_ptr
from quantlib.types cimport Size
from quantlib.models.shortrate._onefactor_model cimport ShortRateModel
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib._time_grid cimport TimeGrid
from .._pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/swaption/treeswaptionengine.hpp' namespace 'QuantLib':
    cdef cppclass TreeSwaptionEngine(PricingEngine):
        TreeSwaptionEngine(const shared_ptr[ShortRateModel],
                           const Size time_steps,
                           Handle[YieldTermStructure] term_structure) # = Handle[YieldTermStructure]()
        TreeSwaptionEngine(shared_ptr[ShortRateModel],
                           const TimeGrid time_grid,
                           Handle[YieldTermStructure] term_structure) # = Handle[YieldTermStructure]()
