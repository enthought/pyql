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
from quantlib.pricingengines cimport _pricing_engine as _pe
cimport quantlib.processes._black_scholes_process as _bsp

from quantlib.handle cimport shared_ptr
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

    def __str__(self):
        return '%s %s %s' % (
            type(self).__name__, str(self.exercise), str(self.payoff)
        )


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

        self._thisptr = new shared_ptr[_instrument.Instrument]( \
            new _option.VanillaOption(payoff_ptr, exercise_ptr)
        )


cdef class EuropeanOption(OneAssetOption):

    def __init__(self, PlainVanillaPayoff payoff, Exercise exercise):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            shared_ptr[_payoffs.StrikedTypePayoff](
                deref(<shared_ptr[_payoffs.StrikedTypePayoff]*>payoff._thisptr)
        )

        cdef shared_ptr[_exercise.Exercise] exercise_ptr = \
            shared_ptr[_exercise.Exercise](
                deref(exercise._thisptr)
            )

        self._thisptr = new shared_ptr[_instrument.Instrument]( \
            new _option.EuropeanOption(payoff_ptr, exercise_ptr)
        )

cdef class DividendVanillaOption(OneAssetOption):
    """ Single-asset vanilla option (no barriers) with discrete dividends. """

    def __init__(self, PlainVanillaPayoff payoff, Exercise exercise, dividend_dates, dividends):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            shared_ptr[_payoffs.StrikedTypePayoff](
                deref(<shared_ptr[_payoffs.StrikedTypePayoff]*>payoff._thisptr)
        )

        cdef shared_ptr[_exercise.Exercise] exercise_ptr = \
            shared_ptr[_exercise.Exercise](
                deref(exercise._thisptr)
        )

        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date]* _dividend_dates = new vector[_date.Date]()
        for date in dividend_dates:
            _dividend_dates.push_back(deref((<Date>date)._thisptr.get()))

        # convert the list of float to a vector of Real
        cdef vector[Real]* _dividends = new vector[Real]()
        for value in dividends:
            _dividends.push_back(<Real>value)

        self._thisptr = new shared_ptr[_instrument.Instrument]( \
            new _option.DividendVanillaOption(
                payoff_ptr, exercise_ptr, deref(_dividend_dates),
                deref(_dividends)
            )
        )

        # cleanup temporary allocated pointers
        del _dividend_dates
        del _dividends

    def impliedVolatility(self, Real targetValue,
        GeneralizedBlackScholesProcess process, Real accuracy, Size maxEvaluations,
        Volatility minVol, Volatility maxVol):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                deref(<shared_ptr[_bsp.GeneralizedBlackScholesProcess]*>process._thisptr)
        )

        vol = (<_option.DividendVanillaOption *> self._thisptr.get()).impliedVolatility(targetValue,
        process_ptr, accuracy, maxEvaluations, minVol, maxVol)

        return vol
