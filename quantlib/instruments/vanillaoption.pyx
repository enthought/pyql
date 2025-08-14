from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.types cimport Real, Size, Volatility
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.processes cimport _black_scholes_process as _bsp
from .dividendschedule cimport DividendSchedule
from ..exercise cimport Exercise
from ..payoffs cimport StrikedTypePayoff
from .. cimport _payoffs

from . cimport _vanillaoption as _va

cdef class VanillaOption(OneAssetOption):

    def __init__(self, StrikedTypePayoff payoff not None, Exercise exercise not None):

        self._thisptr.reset(
            new _va.VanillaOption(
                static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr),
                exercise._thisptr
            )
        )

    def implied_volatility(self, Real price,
                           GeneralizedBlackScholesProcess process,
                           DividendSchedule dividends=None,
                           Real accuracy=1e-4,
                           Size max_evaluations=100,
                           Volatility min_vol=1e-7, Volatility max_vol=4.0):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)
        if dividends is None:
            return (<_va.VanillaOption *>self._thisptr.get()).impliedVolatility(
                price, process_ptr, accuracy, max_evaluations, min_vol, max_vol)
        else:
            return (<_va.VanillaOption *>self._thisptr.get()).impliedVolatility(
                price, process_ptr, dividends.schedule, accuracy, max_evaluations, min_vol, max_vol)
