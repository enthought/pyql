cimport _vasicek as _va
from quantlib.handle cimport Handle, shared_ptr

cdef class Vasicek:

    cdef shared_ptr[_va.Vasicek]* _thisptr
