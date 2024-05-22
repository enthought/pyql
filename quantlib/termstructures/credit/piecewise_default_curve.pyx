include '../../types.pxi'

from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

from . cimport _piecewise_default_curve as _pdc

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.termstructures.credit._credit_helpers as _ch
from .default_probability_helpers cimport CdsHelper, DefaultProbabilityHelper
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

from enum import IntEnum

globals()["ProbabilityTrait"] = IntEnum('ProbabilityTrait',
        [('HazardRate', 0), ('DefaultDensity', 1), ('SurvivalProbability', 2)])
globals()["Interpolator"] = IntEnum('Interpolator',
        [('Linear', 0), ('LogLinear', 1), ('BackwardFlat', 2)])


cdef class PiecewiseDefaultCurve(DefaultProbabilityTermStructure):

    def __init__(self, ProbabilityTrait trait, Interpolator interpolator,
                 Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Real accuracy=1e-12):

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_ch.DefaultProbabilityHelper]] instruments

        for helper in helpers:
            instruments.push_back((<DefaultProbabilityHelper?>helper)._thisptr)

        self._trait = trait
        self._interpolator = interpolator

        if trait == HazardRate:
            if interpolator == Linear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
        elif trait == DefaultDensity:
            if interpolator == Linear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                     new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear](
                         settlement_days, calendar._thisptr, instruments,
                         deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
        else:
            if interpolator == Linear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat](
                        settlement_days, calendar._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))

    @classmethod
    def from_reference_date(cls, ProbabilityTrait trait, Interpolator interpolator,
                            Date reference_date, list helpers,
                            DayCounter daycounter not None, Real accuracy=1e-12):

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_ch.DefaultProbabilityHelper]] instruments

        cdef PiecewiseDefaultCurve instance = cls.__new__(cls)
        for helper in helpers:
            instruments.push_back(
                (<DefaultProbabilityHelper?>helper)._thisptr)

        instance._trait = trait
        instance._interpolator = interpolator

        if trait == HazardRate:
            if interpolator == Linear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
        elif trait == DefaultDensity:
            if interpolator == Linear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                     new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear](
                        reference_date._thisptr,
                        instruments, deref(daycounter._thisptr), accuracy))
            else:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
        else:
            if interpolator == Linear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear](
                        reference_date._thisptr,
                        instruments, deref(daycounter._thisptr), accuracy))
            else:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat](
                        reference_date._thisptr, instruments,
                        deref(daycounter._thisptr), accuracy))

        return instance

    @property
    def times(self):
        """list of curve times"""
        if self._trait == HazardRate:
            if self._interpolator == Linear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear]*>
                        self._thisptr.get()).times()
            elif self._interpolator == LogLinear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear]*>
                        self._thisptr.get()).times()
            else:
                 return (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat]*>
                        self._thisptr.get()).times()
        elif self._trait == DefaultDensity:
            if self._interpolator == Linear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear]*>
                        self._thisptr.get()).times()
            elif self._interpolator == LogLinear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear]*>
                        self._thisptr.get()).times()
            else:
                 return (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat]*>
                        self._thisptr.get()).times()
        else:
            if self._interpolator == Linear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear]*>
                        self._thisptr.get()).times()
            elif self._interpolator == LogLinear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear]*>
                        self._thisptr.get()).times()
            else:
                 return (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat]*>
                        self._thisptr.get()).times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef vector[_date.Date] _dates

        if self._trait == HazardRate:
            if self._interpolator == Linear:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear]*>
                           self._thisptr.get()).dates()
            elif self._interpolator == LogLinear:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear]*>
                           self._thisptr.get()).dates()
            else:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat]*>
                           self._thisptr.get()).dates()
        elif self._trait == DefaultDensity:
            if self._interpolator == Linear:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear]*>
                           self._thisptr.get()).dates()
            elif self._interpolator == LogLinear:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear]*>
                           self._thisptr.get()).dates()
            else:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat]*>
                           self._thisptr.get()).dates()
        else:
            if self._interpolator == Linear:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear]*>
                           self._thisptr.get()).dates()
            elif self._interpolator == LogLinear:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear]*>
                           self._thisptr.get()).dates()
            else:
                _dates =  (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat]*>
                           self._thisptr.get()).dates()
        cdef size_t i
        cdef list r  = []
        cdef _date.Date qldate
        for i in range(_dates.size()):
            r.append(date_from_qldate(_dates[i]))
        return r

    @property
    def data(self):
        """list of curve data"""
        if self._trait == HazardRate:
            if self._interpolator == Linear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear]*>
                        self._thisptr.get()).data()
            elif self._interpolator == LogLinear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear]*>
                        self._thisptr.get()).data()
            else:
                 return (<_pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat]*>
                        self._thisptr.get()).data()
        elif self._trait == DefaultDensity:
            if self._interpolator == Linear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear]*>
                        self._thisptr.get()).data()
            elif self._interpolator == LogLinear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear]*>
                        self._thisptr.get()).data()
            else:
                 return (<_pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat]*>
                        self._thisptr.get()).data()
        else:
            if self._interpolator == Linear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear]*>
                        self._thisptr.get()).data()
            elif self._interpolator == LogLinear:
                return (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear]*>
                        self._thisptr.get()).data()
            else:
                 return (<_pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat]*>
                        self._thisptr.get()).data()
