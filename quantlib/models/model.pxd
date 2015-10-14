"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _model as _mo
from quantlib.handle cimport shared_ptr


cdef class CalibratedModel:

    cdef shared_ptr[_mo.CalibratedModel]* _thisptr

