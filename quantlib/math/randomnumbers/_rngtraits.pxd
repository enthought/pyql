include '../../types.pxi'

from ._inverse_cumulative_rsg cimport InverseCumulativeRsg
from ._sobol_rsg cimport SobolRsg

cdef extern from 'ql/math/distributions/normaldistribution.hpp' namespace 'QuantLib' nogil:
    cdef cppclass InverseCumulativeNormal:
        pass

cdef extern from 'ql/math/randomnumbers/rngtraits.hpp' namespace 'QuantLib' nogil:
    cdef cppclass GenericLowDiscrepancy[URSG, IC]:
        ctypedef InverseCumulativeRsg[URSG, IC] rsg_type

        @staticmethod
        rsg_type make_sequence_generator(Size dimension,
                                         BigNatural seed)

    ctypedef GenericLowDiscrepancy[SobolRsg, InverseCumulativeNormal] LowDiscrepancy
