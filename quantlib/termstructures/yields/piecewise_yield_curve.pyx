include '../../types.pxi'
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

cimport _piecewise_yield_curve as _pyc

from quantlib.handle cimport shared_ptr

cimport _rate_helpers as _rh
cimport quantlib.termstructures._yield_term_structure as _yts


from rate_helpers cimport RateHelper
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.math.interpolation as intpl

cdef class PiecewiseYieldCurve(YieldTermStructure):
    """A piecewise yield curve.

    Parameters
    ----------
    trait : str
        the kind of curve. Must be either 'discount', 'forward' or 'zero'
    interpolator : str
        the kind of interpolator. Must be either 'loglinear', 'linear' or
        'spline'
    settlement_date : quantlib.time.date.Date
        The settlement date
    helpers : list of quantlib.termstructures.rate_helpers.RateHelper
        a list of rate helpers used to create the curve
    day_counter : quantlib.time.day_counter.DayCounter
        the day counter used by this curve
    tolerance : double (default 1e-12)
        the tolerance

    """

    def __init__(self, BootstrapTrait trait, Interpolator interpolator,
                 Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Real accuracy = 1e-12):


        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        self._trait = trait
        self._interpolator = interpolator

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        if trait == Discount:
            if interpolator == Linear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
        elif trait == ZeroYield:
            if interpolator == Linear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
        else:
            if interpolator == Linear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))

    @classmethod
    def from_reference_date(cls, BootstrapTrait trait, Interpolator interpolator,
                            Date reference_date, list helpers,
                            DayCounter daycounter not None, Real accuracy=1e-12):

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        cdef PiecewiseYieldCurve instance = cls.__new__(cls)
        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance._trait = trait
        instance._interpolator = interpolator
        if trait == Discount:
            if interpolator == Linear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
        elif trait == ZeroYield:
            if interpolator == Linear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
        else:
            if interpolator == Linear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
        return instance

    @property
    def data(self):
        """list of curve data"""
        if self._trait == Discount:
            if self._interpolator == Linear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.Linear]*>
                        self._get_term_structure()).data()
            elif self._interpolator == LogLinear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.LogLinear]*>
                        self._get_term_structure()).data()
            else:
                return (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.BackwardFlat]*>
                        self._get_term_structure()).data()
        elif self._trait == ZeroYield:
            if self._interpolator == Linear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.Linear]*>
                        self._get_term_structure()).data()
            elif self._interpolator == LogLinear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.LogLinear]*>
                        self._get_term_structure()).data()
            else:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.BackwardFlat]*>
                        self._get_term_structure()).data()
        else:
            if self._interpolator == Linear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.Linear]*>
                        self._get_term_structure()).data()
            elif self._interpolator == LogLinear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.LogLinear]*>
                        self._get_term_structure()).data()
            else:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.BackwardFlat]*>
                        self._get_term_structure()).data()
    @property
    def times(self):
        """list of curve times"""
        if self._trait == Discount:
            if self._interpolator == Linear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.Linear]*>
                        self._get_term_structure()).times()
            elif self._interpolator == LogLinear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.LogLinear]*>
                        self._get_term_structure()).times()
            else:
                return (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.BackwardFlat]*>
                        self._get_term_structure()).times()
        elif self._trait == ZeroYield:
            if self._interpolator == Linear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.Linear]*>
                        self._get_term_structure()).times()
            elif self._interpolator == LogLinear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.LogLinear]*>
                        self._get_term_structure()).times()
            else:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.BackwardFlat]*>
                        self._get_term_structure()).times()
        else:
            if self._interpolator == Linear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.Linear]*>
                        self._get_term_structure()).times()
            elif self._interpolator == LogLinear:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.LogLinear]*>
                        self._get_term_structure()).times()
            else:
                return (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.BackwardFlat]*>
                        self._get_term_structure()).times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef vector[_date.Date] _dates
        if self._trait == Discount:
            if self._interpolator == Linear:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.Linear]*>
                          self._get_term_structure()).dates()
            elif self._interpolator == LogLinear:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.LogLinear]*>
                          self._get_term_structure()).dates()
            else:
                 _dates =  (<_pyc.PiecewiseYieldCurve[_pyc.Discount, intpl.BackwardFlat]*>
                            self._get_term_structure()).dates()
        elif self._trait == ZeroYield:
            if self._interpolator == Linear:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.Linear]*>
                          self._get_term_structure()).dates()
            elif self._interpolator == LogLinear:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.LogLinear]*>
                          self._get_term_structure()).dates()
            else:
                 _dates = (<_pyc.PiecewiseYieldCurve[_pyc.ZeroYield, intpl.BackwardFlat]*>
                           self._get_term_structure()).dates()
        else:
            if self._interpolator == Linear:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.Linear]*>
                          self._get_term_structure()).dates()
            elif self._interpolator == LogLinear:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.LogLinear]*>
                          self._get_term_structure()).dates()
            else:
                _dates = (<_pyc.PiecewiseYieldCurve[_pyc.ForwardRate, intpl.BackwardFlat]*>
                          self._get_term_structure()).dates()
        cdef size_t i
        cdef list r  = []
        cdef _date.Date qldate
        for i in range(_dates.size()):
            r.append(date_from_qldate(_dates[i]))

        return r
