
from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport _piecewise_default_curve as _pdc

from quantlib.handle cimport shared_ptr
from quantlib.util.compat cimport utf8_array_from_py_string
from quantlib.math._interpolations cimport Linear
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper
from default_probability_helpers cimport CdsHelper
from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure


VALID_TRAITS = ['HazardRate', 'DefaultDensity', 'SurvivalProbability']
VALID_INTERPOLATORS = ['Linear', 'LogLinear', 'BackwardFlat']


cdef class PiecewiseDefaultCurve:


    def __init__(self, str trait, str interpolator, Date reference_date,
                 helpers, DayCounter daycounter, double accuracy=1e-12):

        # validate inputs
        if trait not in VALID_TRAITS:
            raise ValueError(
                'Traits must b in {0}'.format(','.join(VALID_TRAITS))
            )

        if interpolator not in VALID_INTERPOLATORS:
            raise ValueError(
                'Interpolator must be one of {0}'.format(','.join(VALID_INTERPOLATORS))
            )

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python string to C++ string
        cdef string trait_string = utf8_array_from_py_string(trait)
        cdef string interpolator_string = utf8_array_from_py_string(interpolator)

        # convert Python list to std::vector
        cdef vector[shared_ptr[DefaultProbabilityHelper]]* instruments = \
                new vector[shared_ptr[DefaultProbabilityHelper]]()

        for helper in helpers:
            instruments.push_back(
                <shared_ptr[DefaultProbabilityHelper]>deref((<CdsHelper> helper)._thisptr)
            )

        self._thisptr = new shared_ptr[DefaultProbabilityTermStructure](
            _pdc.credit_term_structure_factory(
                trait_string, interpolator_string,
                deref(reference_date._thisptr.get()),
                deref(instruments),
                deref(daycounter._thisptr),
                accuracy
            )
        )

    def survival_probability(self, Date d, bool extrapolate=False):

        return self._thisptr.get().survivalProbability(
            deref(d._thisptr.get()), extrapolate
        )

