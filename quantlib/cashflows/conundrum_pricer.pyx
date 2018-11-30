include '../types.pxi'

from . cimport _conundrum_pricer as _conp
from . cimport _coupon_pricer as _cp
cimport quantlib.termstructures.volatility.swaption._swaption_vol_structure as _svs
from quantlib.termstructures.volatility.swaption.swaption_vol_structure \
    cimport SwaptionVolatilityStructure
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
cimport quantlib._quote as _qt
from quantlib.quotes cimport SimpleQuote

cpdef enum YieldCurveModel:
    Standard = _conp.Standard
    ExactYield = _conp.ExactYield
    ParallelShifts = _conp.ParallelShifts
    NonParallelShifts = _conp.NonParallelShifts


cdef class NumericHaganPricer(CmsCouponPricer):
    def __init__(self, SwaptionVolatilityStructure swaption_vol not None,
                 YieldCurveModel yieldcurve_model,
                 SimpleQuote mean_reversion not None,
                 Rate lower_limit=0.,
                 Rate upper_limit=1.,
                 Real precision=1e-6):

        cdef Handle[_svs.SwaptionVolatilityStructure] swaption_vol_handle = \
            Handle[_svs.SwaptionVolatilityStructure](
                static_pointer_cast[_svs.SwaptionVolatilityStructure](swaption_vol._thisptr))
        cdef Handle[_qt.Quote] mean_reversion_handle = \
            Handle[_qt.Quote](mean_reversion._thisptr)
        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](new _conp.NumericHaganPricer(
            swaption_vol_handle,
            yieldcurve_model,
            mean_reversion_handle,
            lower_limit,
            upper_limit,
            precision
        ))

cdef class AnalyticHaganPricer(CmsCouponPricer):
    def __init__(self, SwaptionVolatilityStructure swaption_vol not None,
                 YieldCurveModel yieldcurve_model,
                 SimpleQuote mean_reversion not None):
        cdef Handle[_svs.SwaptionVolatilityStructure] swaption_vol_handle = \
            Handle[_svs.SwaptionVolatilityStructure](
                static_pointer_cast[_svs.SwaptionVolatilityStructure](swaption_vol._thisptr))
        cdef Handle[_qt.Quote] mean_reversion_handle = \
            Handle[_qt.Quote](mean_reversion._thisptr)
        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](new _conp.AnalyticHaganPricer(
            swaption_vol_handle,
            yieldcurve_model,
            mean_reversion_handle))
