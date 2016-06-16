
from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport _piecewise_default_curve as _pdc

from quantlib.handle cimport shared_ptr
from quantlib.math._interpolations cimport Linear
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper
from default_probability_helpers cimport CdsHelper

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

        # convert Python string to C++ string
        cdef string trait_string = trait.encode('utf-8')
        cdef string interpolator_string = interpolator.encode('utf-8')

        # convert Python list to std::vector
        cdef vector[shared_ptr[DefaultProbabilityHelper]] instruments

        for helper in helpers:
            instruments.push_back(
                <shared_ptr[DefaultProbabilityHelper]>deref((<CdsHelper> helper)._thisptr)
            )

        self._thisptr = _pdc.credit_term_structure_factory(
                trait_string, interpolator_string,
                deref(reference_date._thisptr.get()),
                instruments,
                deref(daycounter._thisptr),
                accuracy
            )
