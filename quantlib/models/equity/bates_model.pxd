"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
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
