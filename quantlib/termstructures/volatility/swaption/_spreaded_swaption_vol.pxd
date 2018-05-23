include '../../../types.pxi'
from _swaption_vol_discrete cimport SwaptionVolatilityStructure
from quantlib.handle cimport Handle
from quantlib._quote cimport Quote

cdef extern from 'ql/termstructures/volatility/swaption/spreadedswaptionvol.hpp' namespace 'QuantLib':
    cdef cppclass SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
         SpreadedSwaptionVolatility(const Handle[SwaptionVolatilityStructure]&,
                                    const Handle[Quote]& spread)
