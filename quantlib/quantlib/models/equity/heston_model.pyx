# distutils: language = c++
# distutils: libraries = QuantLib


cimport _heston_model as _hm

cdef class HestonModelHelper:

    cdef _hm.HestonModelHelper* _thisptr

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
