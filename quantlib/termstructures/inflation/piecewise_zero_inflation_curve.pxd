from quantlib.termstructures.inflation.interpolated_zero_inflation_curve \
    cimport InterpolatedZeroInflationCurve

cdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef enum BootstrapTrait:
    Discount
    ZeroYield
    ForwardRate

cdef class PiecewiseZeroInflationCurve(InterpolatedZeroInflationCurve):
    cdef readonly Interpolator _interpolator
