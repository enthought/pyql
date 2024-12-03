from quantlib.types cimport BigNatural, Size
from ._inverse_cumulative_rsg cimport InverseCumulativeRsg
from ._sobol_rsg cimport SobolRsg
from ._randomsequencegenerator cimport RandomSequenceGenerator
from ._mt19937uniformrng cimport MersenneTwisterUniformRng
from ._zigguratgaussianrng cimport ZigguratGaussianRng
from ._xoshiro256starstaruniformrng cimport Xoshiro256StarStarUniformRng

cdef extern from 'ql/math/distributions/normaldistribution.hpp' namespace 'QuantLib' nogil:
    cdef cppclass InverseCumulativeNormal:
        pass

cdef extern from 'ql/math/randomnumbers/rngtraits.hpp' namespace 'QuantLib' nogil:
    cdef cppclass GenericPseudoRandom[URNG, IC]:
        ctypedef RandomSequenceGenerator[URNG] ursg_type
        ctypedef InverseCumulativeRsg[ursg_type, IC] rsg_type

        @staticmethod
        rsg_type make_sequence_generator(Size dimension,
                                         BigNatural seed)
    ctypedef GenericPseudoRandom[MersenneTwisterUniformRng, InverseCumulativeNormal] PseudoRandom

    cdef cppclass GenericLowDiscrepancy[URSG, IC]:
        ctypedef InverseCumulativeRsg[URSG, IC] rsg_type

        @staticmethod
        rsg_type make_sequence_generator(Size dimension,
                                         BigNatural seed)

    ctypedef GenericLowDiscrepancy[SobolRsg, InverseCumulativeNormal] LowDiscrepancy

ctypedef RandomSequenceGenerator[ZigguratGaussianRng[Xoshiro256StarStarUniformRng]] ZigguratPseudoRandom
