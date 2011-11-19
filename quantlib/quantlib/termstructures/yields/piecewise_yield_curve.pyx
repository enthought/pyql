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

# Plan
# - implemente the RateHelper
# - do not expose the piecewise yield curve but only the termstructure
#   allowing to get down to the curve if needed.


def term_structure_factory(str traits, str interpolator, Date settlement_date,
    rate_helpers, DayCounter day_counter, Real tolerance):

    # convert rate_helpers list to std::vetor

    cdef vector[shared_ptr[RateHelper]]* curve_inputs = new vector[shared_ptr[RateHelper]]()
    for helper in rate_helpers:
        curve_inputs.push_back( deref((<RateHelper>helper)._thisptr))

    cdef shared_ptr[_ff.YieldTermStructure]* ts = _pyc.term_structure_factory(
        string(PyString_AsString(traits)),
        string(PyString_AsString(interpolator)),
        deref(settlement_date._thisptr),
        deref(curve_inputs),
        deref(day_counter._thisptr),
        tolerance
    )



