include '../../types.pxi'

from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport _piecewise_default_curve as _pdc

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper
from default_probability_helpers cimport CdsHelper
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure
cimport quantlib.termstructures._default_term_structure as _dts
VALID_TRAITS = ['HazardRate', 'DefaultDensity', 'SurvivalProbability']
VALID_INTERPOLATORS = ['Linear', 'LogLinear', 'BackwardFlat']

cdef class PiecewiseDefaultCurve(DefaultProbabilityTermStructure):

    def __init__(self, str trait, str interpolator, Date reference_date,
                 list helpers, DayCounter daycounter, double accuracy=1e-12):

        # validate inputs
        if trait not in VALID_TRAITS:
            raise ValueError(
                'Traits must be in {0}'.format(','.join(VALID_TRAITS))
            )

        if interpolator not in VALID_INTERPOLATORS:
            raise ValueError(
                'Interpolator must be one of {0}'.format(','.join(VALID_INTERPOLATORS))
            )

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[DefaultProbabilityHelper]] instruments

        for helper in helpers:
            instruments.push_back(
                <shared_ptr[DefaultProbabilityHelper]>deref((<CdsHelper> helper)._thisptr)
            )

        if trait == "HazardRate":
            if interpolator == "Linear":
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == "LogLinear":
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.HazardRate,_pdc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
        elif trait == "DefaultDensity":
            if interpolator == "Linear":
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == "LogLinear":
                 self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                     <_dts.DefaultProbabilityTermStructure*>
                     new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.LogLinear](
                        deref(reference_date._thisptr.get()),
                        instruments, deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.DefaultDensity,_pdc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
        else:
            if interpolator == "Linear":
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
            elif interpolator == "LogLinear":
                 self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                     <_dts.DefaultProbabilityTermStructure*>
                     new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.LogLinear](
                         deref(reference_date._thisptr.get()),
                         instruments, deref(daycounter._thisptr), accuracy))
            else:
                self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                    <_dts.DefaultProbabilityTermStructure*>
                    new _pdc.PiecewiseDefaultCurve[_pdc.SurvivalProbability,_pdc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy))
