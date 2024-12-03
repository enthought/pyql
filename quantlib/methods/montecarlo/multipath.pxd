from . cimport _multipath as _mp

cdef class MultiPath:
    cdef _mp.MultiPath* _thisptr
