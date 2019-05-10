"""
 Copyright (C) 2014, Enthought Inc
 Copyright (C) 2014, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from . cimport _businessdayconvention as _bdc

cpdef enum:
    Following = _bdc.Following
    ModifiedFollowing = _bdc.ModifiedFollowing
    Preceding = _bdc.Preceding
    ModifiedPreceding = _bdc.ModifiedPreceding
    Unadjusted = _bdc.Unadjusted
    HalfMonthModifiedFollowing = _bdc.HalfMonthModifiedFollowing
    Nearest = _bdc.Nearest

cdef QL_BDC = [Following, ModifiedFollowing,
               Preceding, ModifiedPreceding, Unadjusted,
               HalfMonthModifiedFollowing, Nearest]

_BDC_DICT = {str(BusinessDayConvention(v)).replace(" ",""):v for v in QL_BDC}

cdef class BusinessDayConvention(int):
    __doc__ = 'Valid business day conventions:\n{}'.format(
        '\n'.join(_BDC_DICT.keys())
    )

    def __cinit__(self):
        pass

    @classmethod
    def from_name(cls, name):
        return BusinessDayConvention(_BDC_DICT[name])

    def __str__(self):
        cdef _bdc.stringstream ss
        ss << <_bdc.BusinessDayConvention>(self)
        return ss.str().decode()

    def __repr__(self):
        return 'BusinessDayConvention({})'.format(str(self).replace(" ", ""))
