include '../types.pxi'

# Cython imports
from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector

cimport _bonds #fixme :should move the PricingEngine declaration somewhere else
cimport _exercise
cimport _option
cimport _payoffs
cimport _instrument
cimport quantlib.time._date as _date
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.processes._black_scholes_process as _bsp

from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.instruments.instrument cimport Instrument
from quantlib.instruments.payoffs cimport Payoff, PlainVanillaPayoff
from quantlib.time.date cimport Date
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

cdef public enum ExerciseType:
    American = _exercise.American
    Bermudan  = _exercise.Bermudan
    European = _exercise.European

EXERCISE_TO_STR = {
    American : 'American',
    Bermudan : 'Bermudan',
    European : 'European'
}

cdef class Exercise:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __str__(self):
        return 'Exercise type: %s' % EXERCISE_TO_STR[self._thisptr.get().type()]

    cdef set_exercise(self, shared_ptr[_exercise.Exercise] exc):
        if exc.get() == NULL:
            raise ValueError('Setting the exercise with a null pointer.')
        self._thisptr = new shared_ptr[_exercise.Exercise](exc)

cdef class EuropeanExercise(Exercise):

    def __init__(self, Date exercise_date):
        self._thisptr = new shared_ptr[_exercise.Exercise]( \
            new _exercise.EuropeanExercise(
                deref(exercise_date._thisptr.get())
            )
        )

cdef class AmericanExercise(Exercise):

    def __init__(self, Date latest_exercise_date, Date earliest_exercise_date=None):
        """ Creates an AmericanExercise.

        :param latest_exercise_date: Latest exercise date for the option
        :param earliest_exercise_date: Earliest exercise date for the option (default to None)

        """
        if earliest_exercise_date is not None:
            self._thisptr = new shared_ptr[_exercise.Exercise]( \
                new _exercise.AmericanExercise(
                    deref(earliest_exercise_date._thisptr.get()),
                    deref(latest_exercise_date._thisptr.get())
                )
            )
        else:
            self._thisptr = new shared_ptr[_exercise.Exercise]( \
                new _exercise.AmericanExercise(
                    deref(latest_exercise_date._thisptr.get())
                )
            )

cdef _option.Option* get_option(OneAssetOption option):
    """ Utility function to extract a properly casted VanillaOption out of the
    internal _thisptr attribute of the Instrument base class. """

    cdef _option.Option* ref = <_option.Option*>option._thisptr.get()
    return ref

cdef class OneAssetOption(Instrument):

    def __init__(self):
        raise NotImplementedError(
            'Cannot implement this abstract class. Use child like the '
            'VanillaOption'
        )

    def __str__(self):
        return '%s %s %s' % (
            type(self).__name__, str(self.exercise), str(self.payoff)
        )

    property exercise:
        def __get__(self):
            exercise = Exercise()
            exercise.set_exercise(get_option(self).exercise())
            return exercise

    property payoff:
        def __get__(self):
            payoff = Payoff(0, 0., from_qlpayoff=True)
            payoff.set_payoff(get_option(self).payoff())
            return payoff

    property is_expired:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).isExpired()

    property delta:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).delta()

    property delta_forward:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).deltaForward()

    property elasticity:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).elasticity()

    property gamma:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).gamma()

    property theta:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).theta()

    property theta_per_day:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).thetaPerDay()

    property vega:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).vega()

    property rho:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).rho()

    property dividend_rho:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).dividendRho()

    property strike_sensitivity:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).strikeSensitivity()

    property itm_cash_probability:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).itmCashProbability()


cdef class VanillaOption(OneAssetOption):

    def __init__(self, PlainVanillaPayoff payoff, Exercise exercise):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            shared_ptr[_payoffs.StrikedTypePayoff](
                deref(<shared_ptr[_payoffs.StrikedTypePayoff]*>payoff._thisptr)
        )

        cdef shared_ptr[_exercise.Exercise] exercise_ptr = \
            shared_ptr[_exercise.Exercise](
                deref(exercise._thisptr)
            )

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.VanillaOption(payoff_ptr, exercise_ptr)
        )


    def implied_volatility(self, Real target_value,
        GeneralizedBlackScholesProcess process, Real accuracy, Size max_evaluations,
        Volatility min_vol, Volatility max_vol):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        vol = (<_option.VanillaOption *> self._thisptr.get()).impliedVolatility(
            target_value, process_ptr, accuracy, max_evaluations, min_vol, max_vol)

        return vol

    property delta:
        def __get__(self):
            if self._has_pricing_engine:
                return (<_option.OneAssetOption *> self._thisptr.get()).delta()

cdef class EuropeanOption(VanillaOption):

    def __init__(self, PlainVanillaPayoff payoff, Exercise exercise):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            shared_ptr[_payoffs.StrikedTypePayoff](
                deref(<shared_ptr[_payoffs.StrikedTypePayoff]*>payoff._thisptr)
        )

        cdef shared_ptr[_exercise.Exercise] exercise_ptr = \
            shared_ptr[_exercise.Exercise](
                deref(exercise._thisptr)
            )

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.EuropeanOption(payoff_ptr, exercise_ptr)
        )

cdef class DividendVanillaOption(OneAssetOption):
    """ Single-asset vanilla option (no barriers) with discrete dividends. """

    def __init__(self, PlainVanillaPayoff payoff, Exercise exercise, dividend_dates, vector[Real] dividends):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            shared_ptr[_payoffs.StrikedTypePayoff](
                deref(<shared_ptr[_payoffs.StrikedTypePayoff]*>payoff._thisptr)
        )

        cdef shared_ptr[_exercise.Exercise] exercise_ptr = deref(exercise._thisptr)

        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _dividend_dates
        for date in dividend_dates:
            _dividend_dates.push_back(deref((<Date>date)._thisptr.get()))

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.DividendVanillaOption(
                payoff_ptr, exercise_ptr, _dividend_dates,
                dividends
            )
        )


    def implied_volatility(self, Real target_value,
        GeneralizedBlackScholesProcess process, Real accuracy, Size max_evaluations,
        Volatility min_vol, Volatility max_vol):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        vol = (<_option.DividendVanillaOption *> self._thisptr.get()).impliedVolatility(
            target_value, process_ptr, accuracy, max_evaluations, min_vol, max_vol)

        return vol
