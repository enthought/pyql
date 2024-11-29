from quantlib.models.model cimport ShortRateModel
from quantlib.handle cimport shared_ptr
from . cimport _twofactor_model as _tfm

cdef class ShortRateDynamics:
    cdef shared_ptr[_tfm.TwoFactorModel.ShortRateDynamics] _thisptr

cdef class TwoFactorModel(ShortRateModel):
   pass
