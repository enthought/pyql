cimport _hullwhite_process as _hp
from quantlib.handle cimport Handle, shared_ptr

cdef class HullWhiteProcess:

    cdef shared_ptr[_hp.HullWhiteProcess]* _thisptr
