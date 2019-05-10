from quantlib.math._matrix cimport Matrix as QlMatrix, pseudoSqrt
from . cimport _matrix

cdef class Matrix:
    cdef QlMatrix _thisptr
