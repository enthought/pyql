from quantlib.termstructures.inflation_term_structure cimport ZeroInflationTermStructure

cpdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef class InterpolatedZeroInflationCurve(ZeroInflationTermStructure):
    cdef readonly Interpolator _trait # needed so that we can query
                                      # the original template type
