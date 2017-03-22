from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef enum BootstrapTrait:
    Discount
    ZeroYield
    ForwardRate

cdef class PiecewiseYieldCurve(YieldTermStructure):
    cdef readonly BootstrapTrait _trait
    cdef readonly Interpolator _interpolator
