from quantlib.models.equity.heston_model cimport HestonModel

from quantlib.handle cimport shared_ptr

cdef class BatesModel(HestonModel):
    pass

cdef class BatesDetJumpModel(HestonModel):
    pass

cdef class BatesDoubleExpModel(HestonModel):
    pass

cdef class BatesDoubleExpDetJumpModel(BatesDoubleExpModel):
    pass
