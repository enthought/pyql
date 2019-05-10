"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from libcpp.string cimport string

cdef class Region:
    def __cinit__(self):
        pass

    property name:
        def __get__(self):
            return self._thisptr.name().decode('utf-8')

    property code:
        def __get__(self):
            return self._thisptr.code().decode('utf-8')

    def __str__(self):
        return self._thisptr.name().decode('utf-8')

    @classmethod
    def from_name(cls, code):
        from .region_registry import REGISTRY
        return REGISTRY.from_name(code)


cdef class CustomRegion(Region):
    def __init__(self, str name, str code):
        # convert the Python str to C++ string
        cdef string name_string = name.encode('utf-8')
        cdef string code_string = code.encode('utf-8')

        self._thisptr = new _region.CustomRegion(
            name_string,
            code_string)
