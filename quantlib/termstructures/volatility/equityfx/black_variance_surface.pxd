from .black_vol_term_structure cimport BlackVarianceTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/blackvariancesurface.hpp' namespace 'QuantLib::BlackVarianceSurface':
    cpdef enum Extrapolation:
        ConstantExtrapolation
        InterpolatorDefaultExtrapolation

cdef class BlackVarianceSurface(BlackVarianceTermStructure):
    pass
