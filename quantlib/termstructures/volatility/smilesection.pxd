from quantlib.ext cimport shared_ptr
from . cimport _smilesection as _ss

cdef class SmileSection:
    cdef shared_ptr[_ss.SmileSection] _thisptr
