include '../types.pxi'

# Cython imports
from libcpp cimport bool

from . cimport _option
from . cimport _payoffs
from .exercise cimport Exercise
from quantlib.cashflows.dividend cimport DividendSchedule
cimport quantlib._instrument as _instrument
cimport quantlib.time._date as _date
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.processes._black_scholes_process as _bsp

from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.instruments.payoffs cimport Payoff, StrikedTypePayoff
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

cdef class Option(Instrument):
    def __init__(self):
        raise NotImplementedError(
            'Cannot implement this abstract class. Use child like the '
            'VanillaOption'
        )

    def __str__(self):
        return '%s %s %s' % (
            type(self).__name__, str(self.exercise), str(self.payoff)
        )

    @property
    def exercise(self):
        cdef Exercise ex = Exercise.__new__(Exercise)
        ex._thisptr = (<_option.Option*>self._thisptr.get()).exercise()
        return ex

    @property
    def payoff(self):
        cdef Payoff po = Payoff.__new__(Payoff)
        po._thisptr = (<_option.Option*>self._thisptr.get()).payoff()
        return po

cdef class OneAssetOption(Option):

    cdef inline _option.OneAssetOption* as_ptr(self) nogil:
        return <_option.OneAssetOption*>self._thisptr.get()

    @property
    def delta(self):
        return self.as_ptr().delta()

    @property
    def delta_forward(self):
        return self.as_ptr().deltaForward()

    @property
    def elasticity(self):
        return self.as_ptr().elasticity()

    property gamma:
        def __get__(self):
                return (<_option.OneAssetOption *> self._thisptr.get()).gamma()

    property theta:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).theta()

    property theta_per_day:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).thetaPerDay()

    property vega:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).vega()

    property rho:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).rho()

    property dividend_rho:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).dividendRho()

    property strike_sensitivity:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).strikeSensitivity()

    property itm_cash_probability:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).itmCashProbability()


cdef class VanillaOption(OneAssetOption):

    def __init__(self, StrikedTypePayoff payoff not None, Exercise exercise not None):

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.VanillaOption(
                static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr),
                                      exercise._thisptr)
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
            return (<_option.VanillaOption *>self._thisptr.get()).impliedVolatility(
                price, process_ptr, accuracy, max_evaluations, min_vol, max_vol)
        else:
            return (<_option.VanillaOption *>self._thisptr.get()).impliedVolatility(
                price, process_ptr, dividends.schedule, accuracy, max_evaluations, min_vol, max_vol)


cdef class EuropeanOption(VanillaOption):

    def __init__(self, StrikedTypePayoff payoff not None, Exercise exercise not None):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            static_pointer_cast[_payoffs.StrikedTypePayoff](
                payoff._thisptr)

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.EuropeanOption(payoff_ptr, exercise._thisptr)
        )
