from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

include '../../types.pxi'

cimport quantlib.termstructures.yields._discount_curve as _dc
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
cimport quantlib.math._interpolations as intpl

from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.time._calendar as _calendar

cdef class InterpolatedDiscountCurve(YieldTermStructure):
    """YieldTermStructure based on interpolation of discountFactors

        Parameters
        ----------
        interpolator : int {Linear, LogLinear, BackwardFlat}
            can be one of Linear, LogLinear, BackwardFlat
        dates : :obj:`list` of :class:`~quantlib.time.date.Date`
            list of dates
        dfss: :obj:`list` of float
            corresponding list of discount factors
        day_counter: :class:`~quantlib.time.daycounter.DayCounter`
        cal: :class:`~quantlib.time.calendar.Calendar`

    """
    def __init__(self, Interpolator interpolator, list dates, vector[DiscountFactor] dfs,
                 DayCounter day_counter not None, Calendar cal= Calendar()):
        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _dates
        for date in dates:
            _dates.push_back(deref((<Date?>date)._thisptr.get()))

        self._trait = interpolator

        if interpolator == Linear:
            self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                new _dc.InterpolatedDiscountCurve[intpl.Linear](
                    _dates, dfs, deref(day_counter._thisptr),
                    deref(cal._thisptr)))
            )
        elif interpolator == LogLinear:
            self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                new _dc.InterpolatedDiscountCurve[intpl.LogLinear](
                    _dates, dfs, deref(day_counter._thisptr),
                    deref(cal._thisptr)))
            )
        elif interpolator == BackwardFlat:
            self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                new _dc.InterpolatedDiscountCurve[intpl.BackwardFlat](
                    _dates, dfs, deref(day_counter._thisptr),
                    deref(cal._thisptr)))
            )
        else:
            raise ValueError("interpolator needs to be any of Linear, LogLinear or BackwardFlat")

    @property
    def dates(self):
        """list of curve dates"""
        cdef vector[_date.Date] _dates
        if self._trait == Linear:
            _dates = (<_dc.InterpolatedDiscountCurve[intpl.Linear]*>
                      self._get_term_structure()).dates()
        elif self._trait == LogLinear:
            _dates = (<_dc.InterpolatedDiscountCurve[intpl.LogLinear]*>
                       self._get_term_structure()).dates()
        else:
            _dates = (<_dc.InterpolatedDiscountCurve[intpl.BackwardFlat]*>
                      self._get_term_structure()).dates()
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
            return (<_dc.InterpolatedDiscountCurve[intpl.Linear]*>
                    self._get_term_structure()).times()
        elif self._trait == LogLinear:
            return (<_dc.InterpolatedDiscountCurve[intpl.LogLinear]*>
                    self._get_term_structure()).times()
        else:
            return (<_dc.InterpolatedDiscountCurve[intpl.BackwardFlat]*>
                    self._get_term_structure()).times()

    @property
    def data(self):
        """list of curve data"""
        if self._trait == Linear:
            return (<_dc.InterpolatedDiscountCurve[intpl.Linear]*>
                    self._get_term_structure()).data()
        elif self._trait == LogLinear:
            return (<_dc.InterpolatedDiscountCurve[intpl.LogLinear]*>
                    self._get_term_structure()).data()
        else:
            return (<_dc.InterpolatedDiscountCurve[intpl.BackwardFlat]*>
                     self._get_term_structure()).data()

    @property
    def discounts(self):
        """list of curve discount factors"""
        if self._trait == Linear:
            return (<_dc.InterpolatedDiscountCurve[intpl.Linear]*>
                self._get_term_structure()).discounts()
        elif self._trait == LogLinear:
            return (<_dc.InterpolatedDiscountCurve[intpl.LogLinear]*>
                self._get_term_structure()).discounts()
        else:
            return (<_dc.InterpolatedDiscountCurve[intpl.BackwardFlat]*>
                    self._get_term_structure()).discounts()


cdef class DiscountCurve(InterpolatedDiscountCurve):
    def __init__(self, list dates, vector[DiscountFactor] dfs,
                 DayCounter day_counter not None, Calendar cal = Calendar()):
        InterpolatedDiscountCurve.__init__(self, LogLinear, dates, dfs, day_counter, cal)
