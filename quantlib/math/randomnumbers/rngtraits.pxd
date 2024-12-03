from ._inverse_cumulative_rsg cimport InverseCumulativeRsg
from ._randomsequencegenerator cimport RandomSequenceGenerator
from ._sobol_rsg cimport SobolRsg
from ._rngtraits cimport InverseCumulativeNormal
from ._mt19937uniformrng cimport MersenneTwisterUniformRng
from ._zigguratgaussianrng cimport ZigguratGaussianRng
from ._xoshiro256starstaruniformrng cimport Xoshiro256StarStarUniformRng

cdef class LowDiscrepancy:
    cdef InverseCumulativeRsg[SobolRsg, InverseCumulativeNormal]* _thisptr

cdef class PseudoRandom:
    cdef InverseCumulativeRsg[RandomSequenceGenerator[MersenneTwisterUniformRng], InverseCumulativeNormal]* _thisptr

cdef class FastPseudoRandom:
    cdef RandomSequenceGenerator[ZigguratGaussianRng[Xoshiro256StarStarUniformRng]]* _thisptr
