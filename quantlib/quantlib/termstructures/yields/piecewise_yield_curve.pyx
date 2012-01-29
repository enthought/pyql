include '../../types.pxi'
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp.string cimport string
from cpython.string cimport PyString_AsString

cimport _piecewise_yield_curve as _pyc
cimport _rate_helpers as _rh
cimport _flat_forward as _ff
from quantlib.handle cimport shared_ptr

from rate_helpers cimport RateHelper
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter

from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure

VALID_TRAITS = ['discount', 'forward', 'zero']
VALID_INTERPOLATORS = ['loglinear', 'linear', 'spline']

def term_structure_factory(str traits, str interpolator, Date settlement_date,
    rate_helpers, DayCounter day_counter, Real tolerance):

    # validate inputs
    if traits not in VALID_TRAITS:
        raise ValueError('Traits must be in {}',format(VALID_TRAITS))

    if interpolator not in VALID_INTERPOLATORS:
        raise ValueError(
            'Interpolator must be one of {}'.format(VALID_INTERPOLATORS)
        )

    # convert rate_helpers list to std::vetor
    cdef vector[shared_ptr[RateHelper]]* curve_inputs = new vector[shared_ptr[RateHelper]]()
    for helper in rate_helpers:
        curve_inputs.push_back( deref((<RateHelper>helper)._thisptr))

    # convert the Python str to C++ string
    cdef string traits_string = string(PyString_AsString(traits))
    cdef string interpolator_string = string(PyString_AsString(interpolator)),

    cdef shared_ptr[_ff.YieldTermStructure] ts_ptr = _pyc.term_structure_factory(
        traits_string,
        interpolator_string,
        deref(settlement_date._thisptr.get()),
        deref(curve_inputs),
        deref(day_counter._thisptr),
        tolerance
    )

    term_structure = YieldTermStructure(relinkable=False)
    cdef shared_ptr[_ff.YieldTermStructure]* s_pt = new shared_ptr[_ff.YieldTermStructure](ts_ptr)
    term_structure._thisptr = s_pt
    return term_structure







