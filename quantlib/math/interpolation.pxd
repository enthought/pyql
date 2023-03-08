cimport cython
from . cimport _interpolations as _intpl

cdef class Interpolation:
    pass

@cython.final
cdef class Linear(Interpolation):
    cdef _intpl.Linear _thisptr

@cython.final
cdef class LogLinear(Interpolation):
    cdef _intpl.LogLinear _thisptr

@cython.final
cdef class BackwardFlat(Interpolation):
    cdef _intpl.BackwardFlat _thisptr

@cython.final
cdef class Cubic(Interpolation):
    cdef _intpl.Cubic _thisptr

@cython.final
cdef class Bicubic(Interpolation):
    cdef _intpl.Bicubic _thisptr

@cython.final
cdef class Bilinear(Interpolation):
    cdef _intpl.Bilinear _thisptr
