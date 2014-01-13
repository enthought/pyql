"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _currency as _cu
cimport currency

_VALID_CURRENCY = ['USD', 'EUR']

cdef class Currency:
    def __cinit__(self):
        self._thisptr = new _cu.Currency()

    property name:
        def __get__(self):
            return self._thisptr.name().c_str()

    property code:
        def __get__(self):
            return self._thisptr.code().c_str()

    property symbol:
        def __get__(self):
            return self._thisptr.symbol().c_str()

    property fractionSymbol:
        def __get__(self):
            return self._thisptr.fractionSymbol().c_str()

    property fractionsPerUnit:
        def __get__(self):
            return self._thisptr.fractionsPerUnit()
        
    def __str__(self):
        if not self._thisptr.empty():
            return self._thisptr.name().c_str()
        else:
            return 'null currency'

    @classmethod
    def from_name(cls, name):
        cdef Currency cu = cls()
        if(name == 'USD'):
            cu._thisptr = <_cu.Currency*> new _cu.USDCurrency()
        elif(name == 'EUR'):
            cu._thisptr = <_cu.Currency*> new _cu.EURCurrency()
        else:
            raise ValueError('name must be in {}',format(_VALID_CURRENCY))
        return cu

cdef class USDCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.USDCurrency()

cdef class EURCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.EURCurrency()


