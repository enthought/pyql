from quantlib.termstructures.inflation.interpolated_zero_inflation_curve \
    cimport InterpolatedZeroInflationCurve

cpdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef class PiecewiseZeroInflationCurve(InterpolatedZeroInflationCurve):
    cdef readonly Interpolator _interpolator
