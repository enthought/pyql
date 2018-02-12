from quantlib.math._matrix cimport Matrix as QlMatrix

cdef class Matrix:
    cdef QlMatrix _thisptr
