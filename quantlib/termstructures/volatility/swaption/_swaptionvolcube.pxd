include '../../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.time._date cimport Date, Period
from quantlib.handle cimport shared_ptr, Handle
from quantlib._quote cimport Quote
from _swaption_vol_structure cimport SwaptionVolatilityStructure
from quantlib.indexes._swap_index cimport SwapIndex

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvolcube.hpp' namespace 'QuantLib':
    cdef cppclass SwaptionVolatilityCube:
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
