"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _heston_model as _hm

from quantlib.handle cimport shared_ptr


cdef class HestonModelHelper:

    cdef shared_ptr[_hm.HestonModelHelper]* _thisptr

cdef class HestonModel:

    cdef shared_ptr[_hm.HestonModel]* _thisptr

