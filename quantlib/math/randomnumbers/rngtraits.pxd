from . cimport _rngtraits
from ._inverse_cumulative_rsg cimport InverseCumulativeRsg
from ._sobol_rsg cimport SobolRsg
from ._rngtraits cimport InverseCumulativeNormal

cdef class LowDiscrepancy:
    cdef InverseCumulativeRsg[SobolRsg, InverseCumulativeNormal]* _thisptr
