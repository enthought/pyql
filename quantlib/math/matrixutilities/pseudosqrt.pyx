from ..matrix cimport Matrix
from libcpp.utility cimport move
from .._matrix cimport Matrix as QlMatrix

def pseudo_sqrt(Matrix m, SalvagingAlgorithm algo=Nothing):
    cdef Matrix r = Matrix.__new__(Matrix)
    r._thisptr = move[QlMatrix](pseudoSqrt(m._thisptr, algo))
    return r
