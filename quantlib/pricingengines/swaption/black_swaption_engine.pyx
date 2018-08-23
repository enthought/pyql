include '../../types.pxi'
from cython.operator cimport dereference as deref
from quantlib.pricingengines.engine cimport PricingEngine
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.daycounters.simple cimport Actual365Fixed
from quantlib.quotes cimport Quote
cimport quantlib._quote as _qt
cimport quantlib.termstructures.volatility.swaption._swaption_vol_structure \
    as _svs
from quantlib.termstructures.volatility.swaption.swaption_vol_structure \
    cimport SwaptionVolatilityStructure
from _black_swaption_engine cimport BlackSwaptionEngine as _BlackSwaptionEngine

cpdef enum CashAnnuityModel:
    SwapRate = 0
    DiscountCurve = 1

cdef class BlackSwaptionEngine(PricingEngine):
    """Shifted Lognormal Black-formula swaption engine

    .. warning::

    The engine assumes that the exercise date lies before the
    start date of the passed swap.
    """
    def __init__(self, YieldTermStructure discount_curve not None,
                  vol,
                  DayCounter dc=Actual365Fixed(),
                  Real displacement=0.,
                  CashAnnuityModel model=DiscountCurve):
        cdef Handle[_qt.Quote] quote_handle
        cdef Handle[_svs.SwaptionVolatilityStructure] vol_structure_handle

        if isinstance(vol, float):
            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _BlackSwaptionEngine(discount_curve._thisptr,
                                         <Volatility>vol,
                                         deref(dc._thisptr),
                                         displacement,
                                         <_BlackSwaptionEngine.CashAnnuityModel>model))
        elif isinstance(vol, Quote):
            quote_handle = Handle[_qt.Quote]((<Quote>vol)._thisptr)
            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _BlackSwaptionEngine(discount_curve._thisptr,
                                         quote_handle,
                                         deref(dc._thisptr),
                                         displacement,
                                         <_BlackSwaptionEngine.CashAnnuityModel>model))
        elif isinstance(vol, SwaptionVolatilityStructure):
            vol_structure_handle = Handle[_svs.SwaptionVolatilityStructure](
                static_pointer_cast[_svs.SwaptionVolatilityStructure](
                    (<SwaptionVolatilityStructure>vol)._thisptr))
            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _BlackSwaptionEngine(discount_curve._thisptr,
                                         quote_handle,
                                         deref(dc._thisptr),
                                         displacement,
                                         <_BlackSwaptionEngine.CashAnnuityModel>model))


cdef class BachelierSwaptionEngine(PricingEngine):
    """Normal Bachelier-formula swaption engine

    .. warning::

    The engine assumes that the exercise date lies before the
    start date of the passed swap.
    """
    pass
