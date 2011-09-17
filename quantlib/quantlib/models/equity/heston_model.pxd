cimport _heston_model as _hm

from quantlib.handle cimport shared_ptr


cdef class HestonModelHelper:

    cdef shared_ptr[_hm.HestonModelHelper]* _thisptr

cdef class HestonModel:

    cdef shared_ptr[_hm.HestonModel]* _thisptr

