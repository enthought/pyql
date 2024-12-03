from libc.string cimport memcpy
from quantlib.types cimport BigNatural, Real, Size
from cython.operator cimport dereference as deref
from . cimport _rngtraits
cimport cython
cimport numpy as np
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from quantlib.methods.montecarlo._sample cimport Sample
np.import_array()

cdef class LowDiscrepancy:

    def __init__(self, Size dimension, BigNatural seed=0):
        self._thisptr = new InverseCumulativeRsg[SobolRsg, InverseCumulativeNormal](
                _rngtraits.LowDiscrepancy.make_sequence_generator(dimension, seed)
        )

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
        cdef Sample[vector[Real]]* s = <Sample[vector[Real]]*>&self._thisptr.nextSequence()
        memcpy(np.PyArray_DATA(arr), s.value.data(), self._thisptr.dimension() * sizeof(Real))
        return (s.weight, arr)

    @property
    def dimension(self):
        return self._thisptr.dimension()

    def last_sequence(self):
        return self._thisptr.lastSequence().value


cdef class PseudoRandom:

    def __init__(self, Size dimension, BigNatural seed=0):
        self._thisptr = new _rngtraits.PseudoRandom.rsg_type(
            _rngtraits.PseudoRandom.make_sequence_generator(dimension, seed)
        )

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
        cdef Sample[vector[Real]]* s = <Sample[vector[Real]]*>&self._thisptr.nextSequence()
        memcpy(np.PyArray_DATA(arr), s.value.data(), self._thisptr.dimension() * sizeof(Real))
        return (s.weight, arr)

    @property
    def dimension(self):
        return self._thisptr.dimension()

    def last_sequence(self):
        return self._thisptr.lastSequence().value


cdef class FastPseudoRandom:

    def __init__(self, Size dimension, BigNatural seed=0):
        cdef Xoshiro256StarStarUniformRng* uniform_random = new Xoshiro256StarStarUniformRng(seed)
        cdef ZigguratGaussianRng[Xoshiro256StarStarUniformRng]* rng = new ZigguratGaussianRng[Xoshiro256StarStarUniformRng](deref(uniform_random))
        self._thisptr = new RandomSequenceGenerator[ZigguratGaussianRng[Xoshiro256StarStarUniformRng]](dimension, deref(rng))
        del uniform_random
        del rng

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
        cdef Sample[vector[Real]]* s = <Sample[vector[Real]]*>&self._thisptr.nextSequence()
        memcpy(np.PyArray_DATA(arr), s.value.data(), self._thisptr.dimension() * sizeof(Real))
        return (s.weight, arr)

    @property
    def dimension(self):
        return self._thisptr.dimension()
