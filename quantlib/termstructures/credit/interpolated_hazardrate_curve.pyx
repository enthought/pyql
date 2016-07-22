from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

include '../../types.pxi'

from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

cimport quantlib.termstructures.credit._interpolated_hazardrate_curve as _ihc
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date

from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.time._calendar as _calendar

cdef class InterpolatedHazardRateCurve(DefaultProbabilityTermStructure):
    def __init__(self, Interpolator interpolator, list dates, vector[Rate] hazard_rates,
                 DayCounter day_counter not None, Calendar cal = None):

        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _dates
        for date in dates:
            _dates.push_back(deref((<Date?>date)._thisptr.get()))

        cdef _calendar.Calendar c_cal
        if cal is None:
            c_cal = _calendar.Calendar()
        else:
            c_cal = deref(cal._thisptr)

        self._trait = interpolator

        if interpolator == Linear:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _ihc.InterpolatedHazardRateCurve[_ihc.Linear](
                    _dates, hazard_rates,
                    deref(day_counter._thisptr),
                    c_cal)
            )
        elif interpolator == LogLinear:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _ihc.InterpolatedHazardRateCurve[_ihc.LogLinear](
                    _dates, hazard_rates,
                    deref(day_counter._thisptr),
                    c_cal)
            )
        elif interpolator == BackwardFlat:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _ihc.InterpolatedHazardRateCurve[_ihc.BackwardFlat](
                    _dates, hazard_rates,
                    deref(day_counter._thisptr),
                    c_cal)
            )
        else:
            raise ValueError("interpolator needs to be any of Linear, LogLinear or BackwardFlat")

    @property
    def dates(self):
        cdef vector[_date.Date] _dates
        if self._trait == Linear:
            _dates = (<_ihc.InterpolatedHazardRateCurve[_ihc.Linear]*>
                      self._thisptr.get()).dates()
        elif self._trait == LogLinear:
            _dates = (<_ihc.InterpolatedHazardRateCurve[_ihc.LogLinear]*>
                       self._thisptr.get()).dates()
        else:
            _dates = (<_ihc.InterpolatedHazardRateCurve[_ihc.BackwardFlat]*>
                      self._thisptr.get()).dates()
        cdef size_t i
        cdef list r  = []
        cdef _date.Date qldate
        for i in range(_dates.size()):
            r.append(date_from_qldate(_dates[i]))
        return r

    @property
    def times(self):
        if self._trait == Linear:
            return (<_ihc.InterpolatedHazardRateCurve[_ihc.Linear]*>
                    self._thisptr.get()).times()
        elif self._trait == LogLinear:
            return (<_ihc.InterpolatedHazardRateCurve[_ihc.LogLinear]*>
                    self._thisptr.get()).times()
        else:
            return (<_ihc.InterpolatedHazardRateCurve[_ihc.BackwardFlat]*>
                    self._thisptr.get()).times()

    @property
    def data(self):
         if self._trait == Linear:
            return (<_ihc.InterpolatedHazardRateCurve[_ihc.Linear]*>
                    self._thisptr.get()).data()
         elif self._trait == LogLinear:
             return (<_ihc.InterpolatedHazardRateCurve[_ihc.LogLinear]*>
                     self._thisptr.get()).data()
         else:
             return (<_ihc.InterpolatedHazardRateCurve[_ihc.BackwardFlat]*>
                     self._thisptr.get()).data()

    @property
    def hazard_rates(self):
         if self._trait == Linear:
            return (<_ihc.InterpolatedHazardRateCurve[_ihc.Linear]*>
                    self._thisptr.get()).hazardRates()
         elif self._trait == LogLinear:
             return (<_ihc.InterpolatedHazardRateCurve[_ihc.LogLinear]*>
                     self._thisptr.get()).hazardRates()
         else:
             return (<_ihc.InterpolatedHazardRateCurve[_ihc.BackwardFlat]*>
                     self._thisptr.get()).hazardRates()
