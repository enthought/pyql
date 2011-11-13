include '../../types.pxi'
from cython.operator cimport dereference as deref

cimport _piecewise_yield_curve as _pyc

# Plan
# - implemente the RateHelper
# - do not expose the piecewise yield curve but only the termstructure
#   allowing to get down to the curve if needed.


cdef class RateHelper:
    pass

cdef class PiecewiseYieldCurve:

    pass

