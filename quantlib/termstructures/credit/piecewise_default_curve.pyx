include '../../types.pxi'

from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport _piecewise_default_curve as _pdc

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib.termstructures.credit._credit_helpers as _ch
from default_probability_helpers cimport CdsHelper
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

from enum import IntEnum

globals()["ProbabilityTrait"] = IntEnum('ProbabilityTrait',
                                        'HazardRate DefaultDensity SurvivalProbability', start=0)
globals()["Interpolator"] = IntEnum('Interpolator',
                                    'Linear LogLinear BackwardFlat', start=0)

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
            instruments.push_back(
                <shared_ptr[_ch.DefaultProbabilityHelper]>deref((<CdsHelper?>helper)._thisptr)
            )

        self._trait = trait
        self._interpolator = interpolator

        if trait == HazardRate:
            if interpolator == Linear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
        elif trait == DefaultDensity:
            if interpolator == Linear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                     new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear](
                         settlement_days, deref(calendar._thisptr), instruments,
                         deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
        else:
            if interpolator == Linear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
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
                <shared_ptr[_ch.DefaultProbabilityHelper]>deref((<CdsHelper?>helper)._thisptr)
            )

        instance._trait = trait
        instance._interpolator = interpolator

        if trait == HazardRate:
            if interpolator == Linear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
        elif trait == DefaultDensity:
            if interpolator == Linear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                     new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear](
                        deref(reference_date._thisptr.get()),
                        instruments, deref(daycounter._thisptr), accuracy))
            else:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
        else:
            if interpolator == Linear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == LogLinear:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear](
                        deref(reference_date._thisptr.get()),
                        instruments, deref(daycounter._thisptr), accuracy))
            else:
                instance._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))

        return instance
