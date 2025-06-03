from . cimport _vasicek as _va

from quantlib.models.shortrate.onefactor_model cimport OneFactorAffineModel

cdef class Vasicek(OneFactorAffineModel):
    pass
