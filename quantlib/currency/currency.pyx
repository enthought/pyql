"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _currency as _cu

from quantlib.util.compat cimport py_string_from_utf8_array as to_pystr


cdef class Currency:
    def __cinit__(self):
        self._thisptr = new _cu.Currency()

    property name:
        def __get__(self):
            return to_pystr(self._thisptr.name().c_str())

    property code:
        def __get__(self):
            return to_pystr(self._thisptr.code().c_str())

    property symbol:
        def __get__(self):
            return to_pystr(self._thisptr.symbol().c_str())

    property fractionSymbol:
        def __get__(self):
            return to_pystr(self._thisptr.fractionSymbol().c_str())

    property fractionsPerUnit:
        def __get__(self):
            return self._thisptr.fractionsPerUnit()

    def __str__(self):
        if not self._thisptr.empty():
            return to_pystr(self._thisptr.name().c_str())
        else:
            return 'null currency'

    @classmethod
    def from_name(cls, code):
        from .currency_registry import REGISTRY
        return REGISTRY.from_name(code)

