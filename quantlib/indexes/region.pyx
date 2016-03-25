"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _region as _re

from libcpp.string cimport string
from quantlib.handle cimport Handle, shared_ptr


from quantlib.util.compat cimport py_string_from_utf8_array as to_pystr
from quantlib.util.compat cimport utf8_array_from_py_string


cdef class Region:
    def __cinit__(self):
        pass
    
    property name:
        def __get__(self):
            return to_pystr(self._thisptr.name().c_str())

    property code:
        def __get__(self):
            return to_pystr(self._thisptr.code().c_str())

    def __str__(self):
        return to_pystr(self._thisptr.name().c_str())

    @classmethod
    def from_name(cls, code):
        from .region_registry import REGISTRY
        return REGISTRY.from_name(code)


cdef class CustomRegion(Region):
    def __init__(self, str name, str code):
        # convert the Python str to C++ string
        cdef string name_string = utf8_array_from_py_string(name)
        cdef string code_string = utf8_array_from_py_string(code)

        self._thisptr = new _re.CustomRegion(
            name_string,
            code_string)
        
 
        
