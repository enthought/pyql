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
    rate_helpers, DayCounter day_counter, Real tolerance=1.0e-12):
    """ Returns a YieldTermStructure based on the piecewise yield curve information provided
    as input.

    FIXME: must be removed and replace by PiecewiseYieldCurve

    """

    # validate inputs
    if traits not in VALID_TRAITS:
        raise ValueError('Traits must be in {}',format(VALID_TRAITS))

    if interpolator not in VALID_INTERPOLATORS:
        raise ValueError(
            'Interpolator must be one of {}'.format(VALID_INTERPOLATORS)
        )

    # convert rate_helpers list to std::vetor
    cdef vector[shared_ptr[_rh.RateHelper]]* curve_inputs = new vector[shared_ptr[_rh.RateHelper]]()
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
    term_structure._thisptr = new shared_ptr[_ff.YieldTermStructure](ts_ptr)
    return term_structure

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
    tolerance: float (default 1e-12)
        the tolerance
    """

    def __init__(self, str trait, str interpolator, Date settlement_date,
                 helpers, DayCounter day_counter, float tolerance=1e-12):

        # validate inputs
        if trait not in VALID_TRAITS:
            raise ValueError(
                'Traits must b in {}'.format(','.join(VALID_TRAITS))
            )

        if interpolator not in VALID_INTERPOLATORS:
            raise ValueError(
                'Interpolator must be one of {}'.format(','.join(VALID_INTERPOLATORS))
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

