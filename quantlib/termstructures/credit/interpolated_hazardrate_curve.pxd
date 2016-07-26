from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

cpdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef class InterpolatedHazardRateCurve(DefaultProbabilityTermStructure):
    cdef readonly Interpolator _trait # needed so that we can query
                                      # the original template type
