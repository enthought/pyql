include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator import dereference as deref

from quantlib.termstructures.inflation_term_structure cimport ZeroInflationTermStructure
cimport quantlib.termstructures.inflation._interpolated_zero_inflation_curve as _if
cimport quantlib.time._date as _date
from quantlib.time.date cimport Date, Period
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.handle cimport RelinkableHandle, shared_ptr

cdef class InterpolatedZeroInflationCurve(ZeroInflationTermStructure):
    def __cinit__(self, Interpolator interpolator,
                  Date reference_date, Calendar calendar not None,
                  DayCounter day_counter not None,
                  Period lag not None, Frequency frequency,
                  bool index_is_interpolated, YieldTermStructure yts not None,
                  list dates, vector[Rate] rates):

        cdef vector[_date.Date] _dates
        for date in dates:
            _dates.push_back(deref((<Date>date)._thisptr.get()))

        self._trait = interpolator

        if interpolator == Linear:

            self._thisptr = shared_ptr[_if.InflationTermStructure](
                new _if.InterpolatedZeroInflationCurve[_if.Linear](
                    deref(reference_date._thisptr.get()), deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr.get()), frequency,
                    index_is_interpolated, yts._thisptr,
                    _dates, rates))

        elif interpolator == LogLinear:
            self._thisptr = shared_ptr[_if.InflationTermStructure](
                new _if.InterpolatedZeroInflationCurve[_if.LogLinear](
                    deref(reference_date._thisptr.get()), deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr.get()), frequency,
                    index_is_interpolated, yts._thisptr,
                    _dates, rates))
        elif interpolator == BackwardFlat:
            self._thisptr = shared_ptr[_if.InflationTermStructure](
                new _if.InterpolatedZeroInflationCurve[_if.BackwardFlat](
                    deref(reference_date._thisptr.get()), deref(calendar._thisptr),
                    deref(day_counter._thisptr),
                    deref(lag._thisptr.get()), frequency,
                    index_is_interpolated, yts._thisptr,
                    _dates, rates))
        else:
            raise ValueError("interpolator needs to be any of Linear, LogLinear or BackwardFlat")
