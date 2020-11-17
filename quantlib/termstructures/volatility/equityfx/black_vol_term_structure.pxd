from . cimport _black_vol_term_structure as _bvts
from quantlib.termstructures.vol_term_structure cimport VolatilityTermStructure


cdef class BlackVolTermStructure(VolatilityTermStructure):

    cdef inline _bvts.BlackVolTermStructure* get_bvts(self):
        return <_bvts.BlackVolTermStructure*>self._thisptr.get()


cdef class BlackVolatilityTermStructure(BlackVolTermStructure):
    pass

cdef class BlackVarianceTermStructure(BlackVolTermStructure):
    pass
