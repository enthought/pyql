cimport quantlib.models.equity._bates_model as _bm

from quantlib.handle cimport shared_ptr
from quantlib.models.equity.heston_model cimport HestonModel

cdef class BatesModel(HestonModel):
    pass

cdef class BatesDetJumpModel(BatesModel):
    pass

cdef class BatesDoubleExpModel(HestonModel):
    pass

cdef class BatesDoubleExpDetJumpModel(BatesDoubleExpModel):
    pass
