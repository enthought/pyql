include '../../../types.pxi'
from libcpp.vector cimport vector
from libcpp cimport bool
from _swaption_vol_discrete cimport SwaptionVolatilityDiscrete
from _swaption_vol_structure cimport SwaptionVolatilityStructure
from quantlib.handle cimport Handle, shared_ptr
from quantlib._quote cimport Quote
from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvolcube.hpp' namespace 'QuantLib':
    cdef cppclass SwaptionVolatilityCube(SwaptionVolatilityDiscrete):
        SwaptionVolatilityCube(
            const Handle[SwaptionVolatilityStructure]& atmVolStructure,
            const vector[Period]& optionTenors,
            const vector[Period]& swapTenors,
            const vector[Spread]& strikeSpreads,
            const vector[vector[Handle[Quote]]]& volSpreads,
            const shared_ptr[SwapIndex]& swapIndexBase,
            const shared_ptr[SwapIndex]& shortSwapIndexBase,
            bool vegaWeightedSmileFit)
        Rate atmStrike(const Date& optionDate,
                       const Period& swapTenor)
        Rate atmStrike(const Period& optionTenor,
                       const Period& swapTenor)
        Handle[SwaptionVolatilityStructure] atmVol()
        const vector[Spread]& strikeSpreads()
        const vector[vector[Handle[Quote]]]& volSpreads()
        const shared_ptr[SwapIndex] swapIndexBase()
        const shared_ptr[SwapIndex] shortSwapIndexBase()
        bool vegaWeightedSmileFit()
