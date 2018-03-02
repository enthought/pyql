include '../../types.pxi'
cimport cython
cimport numpy as np
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
np.import_array()

cdef class LowDiscrepancy:

    def __init__(self, Size dimension, BigNatural seed=0):
        self._thisptr = new InverseCumulativeRsg[SobolRsg, InverseCumulativeNormal](
                _rngtraits.LowDiscrepancy.make_sequence_generator(dimension, seed))

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __iter__(self):
        return self

    @cython.boundscheck(False)
    def __next__(self):
        cdef np.npy_intp[1] dims
        dims[0] = self._thisptr.dimension()
        cdef arr = np.PyArray_SimpleNew(1, &dims[0], np.NPY_DOUBLE)
        cdef double[:] r = arr
        cdef size_t i
        cdef vector[double] s = self._thisptr.nextSequence().value
        for i in range(dims[0]):
            r[i] = s[i]
        return arr

    @property
    def dimension(self):
        return self._thisptr.dimension()

    def last_sequence(self):
        return self._thisptr.lastSequence().value
