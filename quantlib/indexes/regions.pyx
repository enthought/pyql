""" Module that contains all the region implementations.

"""

cimport _region as _re

from region cimport Region

cdef class AustraliaRegion(Region):
    def __cinit__(self):
        self._thisptr = <_re.Region*> new _re.AustraliaRegion()

cdef class EURegion(Region):
    def __cinit__(self):
        self._thisptr = <_re.Region*> new _re.EURegion()

cdef class FranceRegion(Region):
    def __cinit__(self):
        self._thisptr = <_re.Region*> new _re.FranceRegion()

cdef class UKRegion(Region):
    def __cinit__(self):
        self._thisptr = <_re.Region*> new _re.UKRegion()

cdef class USRegion(Region):
    def __cinit__(self):
        self._thisptr = <_re.Region*> new _re.USRegion()
