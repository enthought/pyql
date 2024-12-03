from . cimport _path

cdef class Path:
    cdef _path.Path* _thisptr
