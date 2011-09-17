cimport _heston_process as _hp
from quantlib.handle cimport Handle, shared_ptr

cdef class HestonProcess:

    cdef shared_ptr[_hp.HestonProcess]* _thisptr

