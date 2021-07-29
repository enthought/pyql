include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
cimport quantlib.processes._black_scholes_process as _bsp
cimport quantlib.models.equity._bates_model as _bm
cimport quantlib.models.shortrate.onefactormodels._hullwhite as _hw
from . cimport _vanilla as _va
from .._pricing_engine cimport PricingEngine as QlPricingEngine
from quantlib.models.equity.heston_model cimport HestonModel

from quantlib.models.shortrate.onefactormodels.hullwhite cimport HullWhite
from quantlib.processes.hullwhite_process cimport HullWhiteProcess
cimport quantlib.processes._hullwhite_process as _hwp
from quantlib.models.equity.bates_model cimport (BatesModel, BatesDetJumpModel, BatesDoubleExpModel, BatesDoubleExpDetJumpModel)
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.methods.finitedifferences.solvers.fdmbackwardsolver cimport FdmSchemeDesc

cdef class VanillaOptionEngine(PricingEngine):
    pass

cdef class AnalyticEuropeanEngine(VanillaOptionEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        self._thisptr.reset(
            new _va.AnalyticEuropeanEngine(process_ptr)
        )

cdef class BaroneAdesiWhaleyApproximationEngine(VanillaOptionEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        self._thisptr.reset(
            new _va.BaroneAdesiWhaleyApproximationEngine(process_ptr)
        )

cdef class AnalyticHestonEngine(PricingEngine):

    def __init__(self, HestonModel model, int integration_order=144):

        self._thisptr.reset(
            new _va.AnalyticHestonEngine(
                model._thisptr,
                <Size>integration_order
            )
        )

cdef class AnalyticBSMHullWhiteEngine(PricingEngine):

    def __init__(self, Real equity_short_rate_correlation,
            GeneralizedBlackScholesProcess process,
            HullWhite hw_model):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        self._thisptr.reset(
            new _va.AnalyticBSMHullWhiteEngine(
                equity_short_rate_correlation,
                process_ptr,
                static_pointer_cast[_hw.HullWhite](hw_model._thisptr)
            )
        )


cdef class AnalyticHestonHullWhiteEngine(PricingEngine):

    def __init__(self, HestonModel heston_model,
                 HullWhite hw_model,
                 int integration_order=144):

        self._thisptr.reset(
            new _va.AnalyticHestonHullWhiteEngine(
                heston_model._thisptr,
                static_pointer_cast[_hw.HullWhite](hw_model._thisptr),
                <Size>integration_order
            )
        )


cdef class FdHestonHullWhiteVanillaEngine(PricingEngine):
    def __init__(self, HestonModel heston_model,
            HullWhiteProcess hw_process,
            Real corr_equity_short_rate,
            Size t_grid,
            Size x_grid,
            Size v_grid,
            Size r_grid,
            Size damping_steps,
            bool control_variate,
            FdmSchemeDesc desc):

        self._thisptr.reset(
            new _va.FdHestonHullWhiteVanillaEngine(
                heston_model._thisptr,
                static_pointer_cast[_hwp.HullWhiteProcess](hw_process._thisptr),
                corr_equity_short_rate,
                t_grid,
                x_grid,
                v_grid,
                r_grid,
                damping_steps,
                control_variate,
                deref(desc._thisptr)
            )
        )

    def enable_multiple_strikes_caching(self, strikes):
        cdef vector[double] v = strikes
        (<_va.FdHestonHullWhiteVanillaEngine *> self._thisptr.get()).enableMultipleStrikesCaching(v)

cdef class BatesEngine(AnalyticHestonEngine):

    def __init__(self, BatesModel model, int integration_order=144):

        self._thisptr.reset(
            new _va.BatesEngine(
                static_pointer_cast[_bm.BatesModel](model._thisptr),
                <Size>integration_order
            )
        )

cdef class BatesDetJumpEngine(BatesEngine):

    def __init__(self, BatesDetJumpModel model, int integration_order=144):

        self._thisptr.reset(
            new _va.BatesDetJumpEngine(
                static_pointer_cast[_bm.BatesDetJumpModel](model._thisptr),
                <Size>integration_order))

cdef class BatesDoubleExpEngine(AnalyticHestonEngine):

    def __init__(self, BatesDoubleExpModel model, int integration_order=144):

        self._thisptr.reset(
            new _va.BatesDoubleExpEngine(
                static_pointer_cast[_bm.BatesDoubleExpModel](model._thisptr),
                <Size>integration_order))

cdef class BatesDoubleExpDetJumpEngine(BatesDoubleExpEngine):

    def __init__(self, BatesDoubleExpDetJumpModel model, int integration_order=144):

        self._thisptr.reset(
            new _va.BatesDoubleExpDetJumpEngine(
                static_pointer_cast[_bm.BatesDoubleExpDetJumpModel](model._thisptr),
                <Size>integration_order))


cdef class AnalyticDividendEuropeanEngine(PricingEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        self._thisptr.reset(
            new _va.AnalyticDividendEuropeanEngine(process_ptr)
        )
