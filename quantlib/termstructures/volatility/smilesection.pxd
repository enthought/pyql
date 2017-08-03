from quantlib.handle cimport shared_ptr
cimport _smilesection as _ss

cdef class SmileSection:
    cdef shared_ptr[_ss.SmileSection] _thisptr
