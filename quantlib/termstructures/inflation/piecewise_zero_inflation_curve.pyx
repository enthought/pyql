from quantlib.types cimport Real
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

from quantlib.time._period cimport Frequency
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from .inflation_helpers cimport ZeroCouponInflationSwapHelper
from .inflation_traits cimport ZeroInflationTraits
cimport quantlib.math._interpolations as intpl
cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib.termstructures.inflation._piecewise_zero_inflation_curve as _pzic
from .seasonality cimport Seasonality

cdef class PiecewiseZeroInflationCurve(InterpolatedZeroInflationCurve):
    def __init__(self, Interpolator interpolator,
                 Date reference_date not None, Date base_date,
                 Frequency frequency,
                 DayCounter day_counter not None,
                 list instruments, Seasonality seasonality=Seasonality(),
                 Real accuracy=1e-12):

        cdef vector[shared_ptr[ZeroInflationTraits.helper]] instruments_cpp
        cdef object i

        for i in instruments:
            instruments_cpp.push_back((<ZeroCouponInflationSwapHelper?>i)._thisptr)

        self._trait = interpolator

        if interpolator == Interpolator.Linear:
            self._thisptr.reset(
                new _pzic.PiecewiseZeroInflationCurve[intpl.Linear](
                    reference_date._thisptr,
                    base_date._thisptr,
                    frequency,
                    deref(day_counter._thisptr),
                    instruments_cpp,
                    seasonality._thisptr,
                    accuracy
                )
            )


        elif interpolator == Interpolator.LogLinear:
            self._thisptr.reset(
                new _pzic.PiecewiseZeroInflationCurve[intpl.LogLinear](
                    reference_date._thisptr,
                    base_date._thisptr,
                    frequency,
                    deref(day_counter._thisptr),
                    instruments_cpp,
                    seasonality._thisptr,
                    accuracy
                )
            )
        else:
            self._thisptr.reset(
                new _pzic.PiecewiseZeroInflationCurve[intpl.BackwardFlat](
                    reference_date._thisptr,
                    base_date._thisptr,
                    frequency,
                    deref(day_counter._thisptr),
                    instruments_cpp,
                    seasonality._thisptr,
                    accuracy
                )
            )
