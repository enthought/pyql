from quantlib.types cimport Natural, Real, Volatility
from . cimport _swaption
from quantlib.handle cimport shared_ptr, static_pointer_cast, Handle
from quantlib.termstructures.volatility.volatilitytype cimport (
    VolatilityType, ShiftedLognormal )
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.termstructures cimport _yield_term_structure as _yts
from .exercise cimport Exercise
from .swap cimport Type as SwapType
from .fixedvsfloatingswap cimport FixedVsFloatingSwap
from . cimport _fixedvsfloatingswap
from .. cimport _instrument
from . cimport _overnightindexedswap as _ois

cdef class Settlement:
    PhysicalOTC = Method.PhysicalOTC
    PhysicalCleared = Method.PhysicalCleared
    CollateralizedCashPrice = Method.CollateralizedCashPrice
    ParYieldCurve = Method.ParYieldCurve
    Physical = Type.Physical
    Cash = Type.Cash

cdef class Swaption(Option):
    def __init__(self, FixedVsFloatingSwap swap, Exercise exercise not None,
                 Type delivery=Settlement.Physical,
                 Method settlement_method=Settlement.PhysicalOTC):
        self._thisptr.reset(
            new _swaption.Swaption(
                static_pointer_cast[_fixedvsfloatingswap.FixedVsFloatingSwap](swap._thisptr),
                exercise._thisptr,
                delivery,
                settlement_method)
        )

    cdef inline _swaption.Swaption* get_swaption(self) noexcept nogil:
        return <_swaption.Swaption*>self._thisptr.get()

    def implied_volatility(self, Real price,
                           YieldTermStructure discount_curve not None,
                           Volatility guess,
                           Real accuracy=1e-4,
                           Natural max_evaluations=100,
                           Volatility min_vol=1e-7,
                           Volatility max_vol=4.,
                           VolatilityType type=ShiftedLognormal,
                           Real displacement=0.):
        return self.get_swaption().impliedVolatility(
            price,
            Handle[_yts.YieldTermStructure](
                static_pointer_cast[_yts.YieldTermStructure](
                    discount_curve._thisptr
                )
            ),
            guess,
            accuracy,
            max_evaluations,
            min_vol,
            max_vol,
            type,
            displacement)

    @property
    def settlement_type(self):
        return self.get_swaption().settlementType()

    @property
    def settlement_method(self):
        return self.get_swaption().settlementMethod()

    @property
    def type(self):
        return <SwapType>(self.get_swaption().type())

    def underlying(self):
        cdef FixedVsFloatingSwap instance = FixedVsFloatingSwap.__new__(FixedVsFloatingSwap)
        cdef shared_ptr[_fixedvsfloatingswap.FixedVsFloatingSwap] swap = self.get_swaption().underlying()
        instance._thisptr = static_pointer_cast[_instrument.Instrument](swap)
        return instance

    @property
    def vega(self):
        return self._thisptr.get().result[Real](b"vega")

    @property
    def annuity(self):
        return self._thisptr.get().result[Real](b"annuity")

    @property
    def atm_forward(self):
        return self._thisptr.get().result[Real](b"atmForward")

    @property
    def implied_vol(self):
        return self._thisptr.get().result[Real](b"impliedVolatility")

    @property
    def delta(self):
        return self._thisptr.get().result[Real](b"delta")

    @property
    def time_to_expiry(self):
        return self._thisptr.get().result[Real](b"timeToExpiry")

    @property
    def std_dev(self):
        return self._thisptr.get().result[Real](b"stdDev")
