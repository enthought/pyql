include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

from quantlib.time.calendar cimport Calendar
from quantlib.time._period cimport Frequency
from quantlib.time.date cimport Date, Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.inflation.inflation_helpers cimport ZeroCouponInflationSwapHelper
from quantlib.termstructures.inflation.inflation_traits cimport ZeroInflationTraits
cimport quantlib.math._interpolations as intpl
cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib.termstructures.inflation._piecewise_zero_inflation_curve as _pzic

cdef class PiecewiseZeroInflationCurve(InterpolatedZeroInflationCurve):
    def __init__(self, Interpolator interpolator,
                 Date reference_date not None, Calendar calendar not None,
                 DayCounter day_counter not None, Period lag not None,
                 Frequency frequency,
                 Rate base_zero_rate,
                 list instruments, Real accuracy=1e-12):

        cdef vector[shared_ptr[ZeroInflationTraits.helper]] instruments_cpp

        for i in instruments:
            instruments_cpp.push_back((<ZeroCouponInflationSwapHelper?>i)._thisptr)

        self._trait = interpolator

        if interpolator == Interpolator.Linear:
            self._thisptr.reset(
                new _pzic.PiecewiseZeroInflationCurve[intpl.Linear](
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr),
                    frequency, base_zero_rate,
                    instruments_cpp,
                    accuracy))

        elif interpolator == Interpolator.LogLinear:
            self._thisptr.reset(
                new _pzic.PiecewiseZeroInflationCurve[intpl.LogLinear](
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr),
                    frequency, base_zero_rate,
                    instruments_cpp,
                    accuracy))
        else:
            self._thisptr.reset(
                new _pzic.PiecewiseZeroInflationCurve[intpl.BackwardFlat](
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr),
                    frequency, base_zero_rate,
                    instruments_cpp,
                    accuracy))
