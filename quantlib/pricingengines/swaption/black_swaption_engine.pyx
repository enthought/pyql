include '../../types.pxi'
from cython.operator cimport dereference as deref
from quantlib.pricingengines.engine cimport PricingEngine
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.handle cimport HandleYieldTermStructure, HandleSwaptionVolatilityStructure
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.daycounters.simple cimport Actual365Fixed
from quantlib.quote cimport Quote
from ._black_swaption_engine cimport BlackSwaptionEngine as _BlackSwaptionEngine, BachelierSwaptionEngine as _BachelierSwaptionEngine

cpdef enum CashAnnuityModel:
    SwapRate = 0
    DiscountCurve = 1

cdef class BlackSwaptionEngine(PricingEngine):
    """Shifted Lognormal Black-formula swaption engine

    .. warning::
       The engine assumes that the exercise date lies before the
       start date of the passed swap.
    """
    def __init__(self, HandleYieldTermStructure discount_curve not None,
                 vol,
                 DayCounter dc=Actual365Fixed(),
                 Real displacement=0.,
                 CashAnnuityModel model=DiscountCurve,
    ):

        if isinstance(vol, float):
            self._thisptr.reset(
                new _BlackSwaptionEngine(
                    discount_curve.handle(),
                    <Volatility>vol,
                    deref(dc._thisptr),
                    displacement,
                    <_BlackSwaptionEngine.CashAnnuityModel>model,
                )
            )
        elif isinstance(vol, Quote):
            self._thisptr.reset(
                new _BlackSwaptionEngine(
                    discount_curve.handle(),
                    (<Quote>vol).handle(),
                    deref(dc._thisptr),
                    displacement,
                    <_BlackSwaptionEngine.CashAnnuityModel>model,
                )
            )
        elif isinstance(vol, HandleSwaptionVolatilityStructure):
            self._thisptr.reset(
                new _BlackSwaptionEngine(
                    discount_curve.handle(),
                    (<HandleSwaptionVolatilityStructure>vol).handle(),
                    <_BlackSwaptionEngine.CashAnnuityModel>model,
                )
            )
        else:
            raise TypeError()


cdef class BachelierSwaptionEngine(PricingEngine):
    """Normal Bachelier-formula swaption engine

    .. warning::
       The engine assumes that the exercise date lies before the
       start date of the passed swap.
    """
    def __init__(
            self,
            HandleYieldTermStructure discount_curve not None,
            vol,
            DayCounter dc=Actual365Fixed(),
            CashAnnuityModel model=DiscountCurve,
    ):

        if isinstance(vol, float):
            self._thisptr.reset(
                new _BachelierSwaptionEngine(
                    discount_curve.handle(),
                    <Volatility>vol,
                    deref(dc._thisptr),
                    <_BachelierSwaptionEngine.CashAnnuityModel>model,
                )
            )
        elif isinstance(vol, Quote):
            self._thisptr.reset(
                new _BachelierSwaptionEngine(
                    discount_curve.handle(),
                    (<Quote>vol).handle(),
                    deref(dc._thisptr),
                    <_BachelierSwaptionEngine.CashAnnuityModel>model,
                )
            )
        elif isinstance(vol, HandleSwaptionVolatilityStructure):
            self._thisptr.reset(
                new _BachelierSwaptionEngine(
                    discount_curve.handle(),
                    (<HandleSwaptionVolatilityStructure>vol).handle(),
                    <_BachelierSwaptionEngine.CashAnnuityModel>model,
                )
            )
        else:
            raise TypeError()
