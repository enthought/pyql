from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cpdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef class InterpolatedDiscountCurve(YieldTermStructure):
    cdef readonly Interpolator _trait # needed so that we can query
                                      # the original template type

cdef class DiscountCurve(InterpolatedDiscountCurve):
    pass
