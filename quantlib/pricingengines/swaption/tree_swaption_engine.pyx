from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from quantlib.types cimport Size
cimport quantlib.models._model as _mo
from quantlib.models.model cimport ShortRateModel
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time_grid cimport TimeGrid
from . cimport _tree_swaption_engine as _tse

cdef class TreeSwaptionEngine(PricingEngine):
    def __init__(self, ShortRateModel model, time_steps_or_time_grid, YieldTermStructure term_structure=YieldTermStructure()):
        if isinstance(time_steps_or_time_grid, TimeGrid):
            self._thisptr.reset(
                new _tse.TreeSwaptionEngine(static_pointer_cast[_mo.ShortRateModel](model._thisptr),
                                            (<TimeGrid>time_steps_or_time_grid)._thisptr,
                                            term_structure._thisptr)
            )
        elif isinstance(time_steps_or_time_grid, int):
            self._thisptr.reset(
                new _tse.TreeSwaptionEngine(static_pointer_cast[_mo.ShortRateModel](model._thisptr),
                                            <Size>time_steps_or_time_grid,
                                            term_structure._thisptr)
            )
        else:
            raise ValueError("needs to pass either a number of time steps or a TimeGrid")
