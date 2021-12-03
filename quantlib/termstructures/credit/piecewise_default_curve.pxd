from ..default_term_structure cimport DefaultProbabilityTermStructure

cdef enum Interpolator:
    Linear
    LogLinear
    BackwardFlat

cdef enum ProbabilityTrait:
    HazardRate
    DefaultDensity
    SurvivalProbability

cdef class PiecewiseDefaultCurve(DefaultProbabilityTermStructure):
    cdef readonly ProbabilityTrait _trait
    cdef readonly Interpolator _interpolator
