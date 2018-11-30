# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from . cimport _currency as _cu
from cython.operator import dereference as deref

cdef class Currency:
    def __cinit__(self):
        self._thisptr = new _cu.Currency()

    property name:
        def __get__(self):
            return self._thisptr.name().decode('utf-8')

    property code:
        def __get__(self):
            return self._thisptr.code().decode('utf-8')

    property symbol:
        def __get__(self):
            return self._thisptr.symbol().decode('utf-8')

    property fractionSymbol:
        def __get__(self):
            return self._thisptr.fractionSymbol().decode('utf-8')

    property fractionsPerUnit:
        def __get__(self):
            return self._thisptr.fractionsPerUnit()

    def __str__(self):
        if not self._thisptr.empty():
            return self._thisptr.name().decode('utf-8')
        else:
            return 'null currency'

    def __eq__(self, Currency other):
        return deref(self._thisptr) == deref(other._thisptr)

    def __neq__(self, Currency other):
        return deref(self._thisptr) != deref(other._thisptr)

    @classmethod
    def from_name(cls, code):
        from .currency_registry import REGISTRY
        return REGISTRY.from_name(code)
