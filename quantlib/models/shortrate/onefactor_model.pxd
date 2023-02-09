"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.models.model cimport ShortRateModel
from quantlib.handle cimport shared_ptr
from . cimport _onefactor_model as _ofm

cdef class ShortRateDynamics:
    cdef shared_ptr[_ofm.OneFactorModel.ShortRateDynamics] _thisptr

cdef class OneFactorModel(ShortRateModel):
   pass

cdef class OneFactorAffineModel(OneFactorModel):
    pass
