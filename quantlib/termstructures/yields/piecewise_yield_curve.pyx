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

cdef class PiecewiseYieldCurve(YieldTermStructure):
    """A piecewise yield curve.

    Parameters:
    -----------
    trait: str
        the kind of curve. Must be either 'discount', 'forward' or 'zero'
    interpolator: str
        the kind of interpolator. Must be either 'loglinear', 'linear' or
        'spline'
    settlement_date: quantlib.time.date.Date
        The settlement date
    helpers: [RateHelper's]
        a list of rate helper to used to create the curve
    day_counter: quantlib.time.day_counter.DayCounter
        the day counter used by this curve
    tolerance: double (default 1e-12)
        the tolerance
    """

    def __init__(self, str trait, str interpolator, Date settlement_date,
                 helpers, DayCounter day_counter, double tolerance=1e-12):

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
        cdef string trait_string = string(PyString_AsString(trait))
        cdef string interpolator_string = string(PyString_AsString(interpolator)),

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]]* instruments = \
                new vector[shared_ptr[_rh.RateHelper]]()

        for helper in helpers:
            instruments.push_back(
                deref((<RateHelper> helper)._thisptr)
            )

        self._thisptr = new shared_ptr[_ff.YieldTermStructure](
            _pyc.term_structure_factory(
                    trait_string,
                    interpolator_string,
                    deref(settlement_date._thisptr.get()),
                    deref(instruments),
                    deref(day_counter._thisptr),
                    tolerance
            )
        )

