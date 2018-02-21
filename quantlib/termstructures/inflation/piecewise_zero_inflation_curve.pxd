from .interpolated_zero_inflation_curve \
    cimport InterpolatedZeroInflationCurve, Interpolator

cdef class PiecewiseZeroInflationCurve(InterpolatedZeroInflationCurve):
    cdef readonly Interpolator _interpolator
