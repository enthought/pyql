include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
cimport quantlib.processes._black_scholes_process as _bsp
cimport quantlib.models.equity._bates_model as _bm

from quantlib.models.equity.heston_model cimport HestonModel
from quantlib.models.equity.bates_model cimport (BatesModel, BatesDetJumpModel, BatesDoubleExpModel, BatesDoubleExpDetJumpModel)
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

from quantlib.pricingengines.engine cimport PricingEngine

cdef class VanillaOptionEngine(PricingEngine):

    pass

cdef class AnalyticEuropeanEngine(VanillaOptionEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                deref(process._thisptr)
            )

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](\
            new _vanilla.AnalyticEuropeanEngine(process_ptr)
        )

cdef class BaroneAdesiWhaleyApproximationEngine(VanillaOptionEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                deref(process._thisptr)
            )

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](
            new _vanilla.BaroneAdesiWhaleyApproximationEngine(process_ptr)
        )

cdef class AnalyticHestonEngine(PricingEngine):

    def __init__(self, HestonModel model, int integration_order=144):

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](
            new _vanilla.AnalyticHestonEngine(
                deref(model._thisptr),
                <Size>integration_order
            )
        )

cdef class BatesEngine(AnalyticHestonEngine):

    def __init__(self, BatesModel model, int integration_order=144):

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](
            new _vanilla.BatesEngine(
                deref(<shared_ptr[_bm.BatesModel]*> model._thisptr),
                <Size>integration_order
            )
        )

cdef class BatesDetJumpEngine(BatesEngine):

    def __init__(self, BatesDetJumpModel model, int integration_order=144):

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](
            new _vanilla.BatesDetJumpEngine(
                deref(<shared_ptr[_bm.BatesDetJumpModel]*> model._thisptr),
                <Size>integration_order))

cdef class BatesDoubleExpEngine(AnalyticHestonEngine):

    def __init__(self, BatesDoubleExpModel model, int integration_order=144):

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](
            new _vanilla.BatesDoubleExpEngine(
                deref(<shared_ptr[_bm.BatesDoubleExpModel]*> model._thisptr),
                <Size>integration_order))

cdef class BatesDoubleExpDetJumpEngine(BatesDoubleExpEngine):

    def __init__(self, BatesDoubleExpDetJumpModel model, int integration_order=144):

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](
            new _vanilla.BatesDoubleExpDetJumpEngine(
                deref(<shared_ptr[_bm.BatesDoubleExpDetJumpModel]*> model._thisptr),
                <Size>integration_order))


cdef class AnalyticDividendEuropeanEngine(PricingEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                deref(process._thisptr)
            )

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](\
            new _vanilla.AnalyticDividendEuropeanEngine(process_ptr)
        )


cdef class FDDividendAmericanEngine(PricingEngine):

    def __init__(self, scheme, GeneralizedBlackScholesProcess process, timesteps, gridpoints):

        # FIXME: first implementation using a fixed scheme!
        print 'Warning : rough implementation using CrankNicolson schema'
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                deref(process._thisptr)
            )

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](\
            new _vanilla.FDDividendAmericanEngine[_vanilla.CrankNicolson](
                process_ptr, timesteps, gridpoints
            )
        )

cdef class FDAmericanEngine(PricingEngine):

    def __init__(self, scheme, GeneralizedBlackScholesProcess process, timesteps, gridpoints):

        # FIXME: first implementation using a fixed scheme!
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                deref(process._thisptr)
            )

        self._thisptr = new shared_ptr[_vanilla.PricingEngine](\
            new _vanilla.FDAmericanEngine[_vanilla.CrankNicolson](
                process_ptr, timesteps, gridpoints
            )
        )


