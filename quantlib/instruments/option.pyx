include '../types.pxi'

# Cython imports
from cython.operator cimport dereference as deref, preincrement as preinc
from libcpp cimport bool
from libcpp.vector cimport vector

from . cimport _option
from . cimport _payoffs
cimport quantlib._instrument as _instrument
cimport quantlib.time._date as _date
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.processes._black_scholes_process as _bsp

from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.instruments.payoffs cimport Payoff, PlainVanillaPayoff
from quantlib.time._date cimport Date as QlDate
from quantlib.time.date cimport Date, _pydate_from_qldate
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

cpdef enum ExerciseType:
    American = _exercise.American
    Bermudan  = _exercise.Bermudan
    European = _exercise.European

cpdef enum OptionType:
    Call = _option.Type.Call
    Put  = _option.Type.Put


cdef class Exercise:

    def __str__(self):
        return "Exercise type: {}".format(ExerciseType(self._thisptr.get().type()).name)

    @property
    def last_date(self):
        return _pydate_from_qldate(self._thisptr.get().lastDate())

    def dates(self):
        cdef vector[QlDate].const_iterator it = self._thisptr.get().dates().const_begin()
        cdef list r = []
        while it != self._thisptr.get().dates().end():
            r.append(_pydate_from_qldate(deref(it)))
            preinc(it)

    @property
    def type(self):
       return ExerciseType(self._thisptr.get().type())

cdef class EuropeanExercise(Exercise):

    def __init__(self, Date exercise_date not None):
        self._thisptr.reset(
            new _exercise.EuropeanExercise(
                deref(exercise_date._thisptr)
            )
        )

cdef class AmericanExercise(Exercise):

    def __init__(self, Date latest_exercise_date, Date earliest_exercise_date=None):
        """ Creates an AmericanExercise.

        :param latest_exercise_date: Latest exercise date for the option
        :param earliest_exercise_date: Earliest exercise date for the option (default to None)

        """
        if earliest_exercise_date is not None:
            self._thisptr = shared_ptr[_exercise.Exercise]( \
                new _exercise.AmericanExercise(
                    deref(earliest_exercise_date._thisptr),
                    deref(latest_exercise_date._thisptr)
                )
            )
        else:
            self._thisptr = shared_ptr[_exercise.Exercise]( \
                new _exercise.AmericanExercise(
                    deref(latest_exercise_date._thisptr)
                )
            )

cdef inline _option.OneAssetOption* get_oneasset_option(OneAssetOption option):
    """ Utility function to extract a properly casted OneAssetOption out of the
    internal _thisptr attribute of the Instrument base class. """

    return <_option.OneAssetOption*>option._thisptr.get()


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

    @property
    def delta(self):
        return get_oneasset_option(self).delta()

    @property
    def delta_forward(self):
        return get_oneasset_option(self).deltaForward()

    property elasticity:
        def __get__(self):
            return (<_option.OneAssetOption *> self._thisptr.get()).elasticity()

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

    def __init__(self, PlainVanillaPayoff payoff not None, Exercise exercise not None):

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.VanillaOption(
                static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr),
                                      exercise._thisptr)
        )


    def implied_volatility(self, Real target_value,
        GeneralizedBlackScholesProcess process, Real accuracy, Size max_evaluations,
        Volatility min_vol, Volatility max_vol):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)

        return (<_option.VanillaOption *>self._thisptr.get()).impliedVolatility(
            target_value, process_ptr, accuracy, max_evaluations, min_vol, max_vol)

cdef class EuropeanOption(VanillaOption):

    def __init__(self, PlainVanillaPayoff payoff not None, Exercise exercise not None):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            static_pointer_cast[_payoffs.StrikedTypePayoff](
                payoff._thisptr)

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.EuropeanOption(payoff_ptr, exercise._thisptr)
        )

cdef class DividendVanillaOption(OneAssetOption):
    """ Single-asset vanilla option (no barriers) with discrete dividends. """

    def __init__(self, PlainVanillaPayoff payoff not None, Exercise exercise not None,
                 dividend_dates, vector[Real] dividends):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr)

        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _dividend_dates
        for date in dividend_dates:
            _dividend_dates.push_back(deref((<Date>date)._thisptr))

        self._thisptr = shared_ptr[_instrument.Instrument]( \
            new _option.DividendVanillaOption(
                payoff_ptr, exercise._thisptr, _dividend_dates,
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
