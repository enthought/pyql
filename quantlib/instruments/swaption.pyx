include '../types.pxi'
cimport _swaption
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.termstructures.volatility.volatilitytype cimport (
    VolatilityType, ShiftedLognormal )
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from .option cimport Exercise
from .swap cimport VanillaSwap
cimport _vanillaswap
cimport _instrument

cdef class Swaption(Instrument):
    def __init__(self, VanillaSwap swap not None, Exercise exercise not None,
                 SettlementType delivery=Physical):
        self._thisptr = shared_ptr[_instrument.Instrument](
            new _swaption.Swaption(
                static_pointer_cast[_vanillaswap.VanillaSwap](swap._thisptr),
                exercise._thisptr,
                <Settlement.Type>delivery))

    def implied_volatility(self, Real price,
                           YieldTermStructure discount_curve not None,
                           Volatility guess,
                           Real accuracy=1e-4,
                           Natural max_evaluations=100,
                           Volatility min_vol=1e-7,
                           Volatility max_vol=4.,
                           VolatilityType type=ShiftedLognormal,
                           Real displacement=0.):
        return (<_swaption.Swaption*>self._thisptr.get()).impliedVolatility(
            price,
            discount_curve._thisptr,
            guess,
            accuracy,
            max_evaluations,
            min_vol,
            max_vol,
            type,
            displacement)

    @property
    def settlement_type(self):
        return SettlementType((<_swaption.Swaption*>self._thisptr.get()).settlementType())

    def underlying_swap(self):
        cdef VanillaSwap instance = VanillaSwap.__new__(VanillaSwap)
        instance._thisptr = static_pointer_cast[_instrument.Instrument](
            (<_swaption.Swaption*>self._thisptr.get()).
            underlyingSwap())
        return instance
