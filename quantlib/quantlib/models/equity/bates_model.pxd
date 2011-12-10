cimport quantlib.models.equity._bates_model as _bm

from quantlib.handle cimport shared_ptr

cdef class BatesModel:
    cdef shared_ptr[_bm.BatesModel]* _thisptr

cdef class BatesDetJumpModel(BatesModel):
    pass

cdef class BatesDoubleExpModel(BatesModel):
    pass

cdef class BatesDoubleExpDetJumpModel(BatesModel):
    pass
