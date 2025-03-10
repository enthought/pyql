from quantlib.types cimport Rate
from libcpp.vector cimport vector
from cython.operator import dereference as deref

cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib.termstructures.inflation._interpolated_zero_inflation_curve as _izic
cimport quantlib.math._interpolations as intpl
cimport quantlib.time._date as _date
from quantlib.time.date cimport Date, Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
from .seasonality cimport Seasonality

cdef class InterpolatedZeroInflationCurve(ZeroInflationTermStructure):
    def __init__(self, Interpolator interpolator,
                 Date reference_date, list dates, vector[Rate] rates,
                 Frequency frequency,
                 DayCounter day_counter not None,
                 Seasonality seasonality):

        cdef vector[_date.Date] _dates
        cdef object date

        for date in dates:
            _dates.push_back((<Date?>date)._thisptr)

        self._trait = interpolator

        if interpolator == Linear:

            self._thisptr.reset(
                new _izic.InterpolatedZeroInflationCurve[intpl.Linear](
                    reference_date._thisptr, _dates,
                    rates, frequency,
                    deref(day_counter._thisptr), seasonality._thisptr)
            )
        elif interpolator == LogLinear:
            self._thisptr.reset(
                new _izic.InterpolatedZeroInflationCurve[intpl.LogLinear](
                    reference_date._thisptr, _dates,
                    rates, frequency,
                    deref(day_counter._thisptr), seasonality._thisptr)
            )

        elif interpolator == BackwardFlat:
            self._thisptr.reset(
                new _izic.InterpolatedZeroInflationCurve[intpl.BackwardFlat](
                    reference_date._thisptr, _dates,
                    rates, frequency,
                    deref(day_counter._thisptr), seasonality._thisptr)
            )
        else:
            raise ValueError("interpolator needs to be any of Linear, LogLinear or BackwardFlat")

    def data(self):
        if self._trait == Linear:
            return (<_izic.InterpolatedZeroInflationCurve[intpl.Linear]*>
                    self._thisptr.get()).data()
        elif self._trait == LogLinear:
            return (<_izic.InterpolatedZeroInflationCurve[intpl.LogLinear]*>
                    self._thisptr.get()).data()
        elif self._trait == BackwardFlat:
            return (<_izic.InterpolatedZeroInflationCurve[intpl.BackwardFlat]*>
                    self._thisptr.get()).data()
