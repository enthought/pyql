cimport cython
from . cimport _interpolations as _intpl

@cython.final
cdef class Linear:
    cdef _intpl.Linear _thisptr

@cython.final
cdef class LogLinear:
    cdef _intpl.LogLinear _thisptr

@cython.final
cdef class BackwardFlat:
    cdef _intpl.BackwardFlat _thisptr
