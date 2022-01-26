include '../types.pxi'
from . cimport _swaption
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.termstructures.volatility.volatilitytype cimport (
    VolatilityType, ShiftedLognormal )
cimport quantlib.termstructures.volatility._volatilitytype as _voltype
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from .option cimport Exercise
from .swap import SwapType
from .vanillaswap cimport VanillaSwap
from . cimport _vanillaswap
from . cimport _instrument

cdef class Swaption(Option):
    def __init__(self, VanillaSwap swap not None, Exercise exercise not None,
                 SettlementType delivery=Physical,
                 SettlementMethod settlement_method=PhysicalOTC):
        self._thisptr = shared_ptr[_instrument.Instrument](
            new _swaption.Swaption(
                static_pointer_cast[_vanillaswap.VanillaSwap](swap._thisptr),
                exercise._thisptr,
                <Settlement.Type>delivery,
                <Settlement.Method>settlement_method)
        )

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
            <_voltype.VolatilityType>type,
            displacement)

    @property
    def settlement_type(self):
        return SettlementType((<_swaption.Swaption*>self._thisptr.get()).settlementType())

    @property
    def settlement_method(self):
        return SettlementMethod((<_swaption.Swaption*>self._thisptr.get()).settlementMethod())

    def underlying_swap(self):
        cdef VanillaSwap instance = VanillaSwap.__new__(VanillaSwap)
        instance._thisptr = static_pointer_cast[_instrument.Instrument](
            (<_swaption.Swaption*>self._thisptr.get()).
            underlyingSwap())
        return instance

    @property
    def type(self):
        return SwapType((<_swaption.Swaption*>self._thisptr.get()).type())

    @property
    def vega(self):
        return self._thisptr.get().result[Real](b"vega")

    @property
    def annuity(self):
        return self._thisptr.get().result[Real](b"annuity")

    @property
    def atm_forward(self):
        return self._thisptr.get().result[Real](b"atmForward")
