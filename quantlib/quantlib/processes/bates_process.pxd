cimport _heston_process as _hp
from quantlib.handle cimport Handle, shared_ptr

cdef class BatesProcess:

    cdef shared_ptr[_hp.BatesProcess]* _thisptr

