from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cpdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cpdef enum BootstrapTrait:
    Discount
    ZeroYield
    ForwardRate

cdef class PiecewiseYieldCurve(YieldTermStructure):
    cdef readonly BootstrapTrait _trait
    cdef readonly Interpolator _interpolator
