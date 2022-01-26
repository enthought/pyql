from quantlib.quote cimport Quote
from quantlib.handle cimport Handle, shared_ptr, make_shared
from . cimport _swaption_vol_structure as _svs
from ..._vol_term_structure cimport VolatilityTermStructure

cdef class SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
    def __init__(self, vs not None,
                 Quote spread not None):

        self._derived_ptr = make_shared[_ssv.SpreadedSwaptionVolatility](
            SwaptionVolatilityStructure.swaption_vol_handle(vs), spread.handle()
        )
        self._thisptr = self._derived_ptr
