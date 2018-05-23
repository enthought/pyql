from quantlib.quotes cimport Quote
from quantlib.handle cimport Handle, shared_ptr
cimport _swaption_vol_structure as _svs
cimport quantlib._quote as _qt

cdef class SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
    def __init__(self, SwaptionVolatilityStructure vs not None,
                 Quote spread not None):

        cdef Handle[_svs.SwaptionVolatilityStructure] vs_handle = \
            Handle[_svs.SwaptionVolatilityStructure](vs._thisptr)
        cdef Handle[_qt.Quote] spread_handle = Handle[_qt.Quote](spread._thisptr)

        self._thisptr = shared_ptr[_svs.SwaptionVolatilityStructure](
            new _ssv.SpreadedSwaptionVolatility(vs_handle, spread_handle))
