from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

include '../../types.pxi'

cimport quantlib.termstructures.credit._interpolated_hazardrate_curve as _ihc
cimport quantlib.termstructures._default_term_structure as _dts
cimport quantlib.math._interpolations as intpl
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date

from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.time._calendar as _calendar

cdef class InterpolatedHazardRateCurve(DefaultProbabilityTermStructure):
    """DefaultProbabilityTermStructure based on interpolation of hazard rates

        Parameters
        ----------
        interpolator : int {Linear, LogLinear, BackwardFlat}
            can be one of Linear, LogLinear, BackwardFlat
        dates : :obj:`list` of :class:`~quantlib.time.date.Date`
            list of dates
        hazard_rates: :obj:`list` of float
            corresponding list of hazard rates
        day_counter: :class:`~quantlib.time.daycounter.DayCounter`
        cal: :class:`~quantlib.time.calendar.Calendar`

    """
    def __init__(self, Interpolator interpolator, list dates, vector[Rate] hazard_rates,
                 DayCounter day_counter not None, Calendar cal=Calendar()):
        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _dates
        for date in dates:
            _dates.push_back(deref((<Date?>date)._thisptr.get()))


        self._trait = interpolator

        if interpolator == Linear:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _ihc.InterpolatedHazardRateCurve[intpl.Linear](
                    _dates, hazard_rates,
                    deref(day_counter._thisptr),
                    deref(cal._thisptr))
            )
        elif interpolator == LogLinear:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _ihc.InterpolatedHazardRateCurve[intpl.LogLinear](
                    _dates, hazard_rates,
                    deref(day_counter._thisptr),
                    deref(cal._thisptr))
            )
        elif interpolator == BackwardFlat:
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _ihc.InterpolatedHazardRateCurve[intpl.BackwardFlat](
                    _dates, hazard_rates,
                    deref(day_counter._thisptr),
                    deref(cal._thisptr))
            )
        else:
            raise ValueError("interpolator needs to be any of Linear, LogLinear or BackwardFlat")

    @property
    def dates(self):
        """list of curve dates"""
        cdef vector[_date.Date] _dates
        if self._trait == Linear:
            _dates = (<_ihc.InterpolatedHazardRateCurve[intpl.Linear]*>
                      self._thisptr.get()).dates()
        elif self._trait == LogLinear:
            _dates = (<_ihc.InterpolatedHazardRateCurve[intpl.LogLinear]*>
                       self._thisptr.get()).dates()
        else:
            _dates = (<_ihc.InterpolatedHazardRateCurve[intpl.BackwardFlat]*>
                      self._thisptr.get()).dates()
        cdef size_t i
        cdef list r  = []
        cdef _date.Date qldate
        for i in range(_dates.size()):
            r.append(date_from_qldate(_dates[i]))
        return r

    @property
    def times(self):
        """list of curve times"""
        if self._trait == Linear:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.Linear]*>
                    self._thisptr.get()).times()
        elif self._trait == LogLinear:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.LogLinear]*>
                    self._thisptr.get()).times()
        else:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.BackwardFlat]*>
                    self._thisptr.get()).times()

    @property
    def data(self):
        """list of curve data"""
        if self._trait == Linear:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.Linear]*>
                    self._thisptr.get()).data()
        elif self._trait == LogLinear:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.LogLinear]*>
                    self._thisptr.get()).data()
        else:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.BackwardFlat]*>
                     self._thisptr.get()).data()

    @property
    def hazard_rates(self):
        """list of curve hazard rates"""
        if self._trait == Linear:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.Linear]*>
                self._thisptr.get()).hazardRates()
        elif self._trait == LogLinear:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.LogLinear]*>
                self._thisptr.get()).hazardRates()
        else:
            return (<_ihc.InterpolatedHazardRateCurve[intpl.BackwardFlat]*>
                    self._thisptr.get()).hazardRates()
