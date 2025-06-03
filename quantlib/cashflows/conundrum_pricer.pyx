from quantlib.types cimport Rate, Real
from . cimport _conundrum_pricer as _conp
from quantlib.handle cimport HandleSwaptionVolatilityStructure
from quantlib.quote cimport Quote

cpdef enum YieldCurveModel:
    Standard = _conp.Standard
    ExactYield = _conp.ExactYield
    ParallelShifts = _conp.ParallelShifts
    NonParallelShifts = _conp.NonParallelShifts


cdef class NumericHaganPricer(CmsCouponPricer):
    def __init__(self, HandleSwaptionVolatilityStructure swaption_vol not None,
                 YieldCurveModel yieldcurve_model,
                 Quote mean_reversion not None,
                 Rate lower_limit=0.,
                 Rate upper_limit=1.,
                 Real precision=1e-6):

        self._thisptr.reset(
            new _conp.NumericHaganPricer(
                swaption_vol.handle(),
                yieldcurve_model,
                mean_reversion.handle(),
                lower_limit,
                upper_limit,
                precision
            )
        )

cdef class AnalyticHaganPricer(CmsCouponPricer):
    def __init__(self, HandleSwaptionVolatilityStructure swaption_vol not None,
                 YieldCurveModel yieldcurve_model,
                 Quote mean_reversion not None):
        self._thisptr.reset(
            new _conp.AnalyticHaganPricer(
                swaption_vol.handle(),
                yieldcurve_model,
                mean_reversion.handle()
            )
        )
