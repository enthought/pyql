"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from quantlib.models.model cimport CalibratedModel
cimport quantlib.models.shortrate._onefactor_model as _ofm

cdef class OneFactorAffineModel(CalibratedModel):

    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate OneFactorAffineModel')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def discount_bound(self, Time now, Time maturity, Rate rate):
        return (<_ofm.OneFactorAffineModel*>self._thisptr.get()).discountBond(
            now, maturity, rate)
