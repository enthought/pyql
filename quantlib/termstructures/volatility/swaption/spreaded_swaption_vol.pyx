from quantlib.quote cimport Quote
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from . cimport _swaption_vol_structure as _svs
from ..._vol_term_structure cimport VolatilityTermStructure

cdef class SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
    def __init__(self, SwaptionVolatilityStructure vs not None,
                 Quote spread not None):

        cdef Handle[_svs.SwaptionVolatilityStructure] vs_handle = \
            Handle[_svs.SwaptionVolatilityStructure](
                static_pointer_cast[_svs.SwaptionVolatilityStructure](vs._thisptr))
        self._thisptr = shared_ptr[VolatilityTermStructure](
            new _ssv.SpreadedSwaptionVolatility(vs_handle, spread.handle()))
