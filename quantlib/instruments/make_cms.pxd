include '../types.pxi'

cimport _make_cms

cdef class MakeCms:
    cdef _make_cms.MakeCms* _thisptr
