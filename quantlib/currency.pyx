"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.settings import utf8_char_array_to_py_compat_str
cimport _currency as _cu
cimport currency
from quantlib.util.prettyprint import prettyprint

cdef class Currency:
    def __cinit__(self):
        self._thisptr = new _cu.Currency()

    property name:
        def __get__(self):
            return utf8_char_array_to_py_compat_str(self._thisptr.name().c_str())

    property code:
        def __get__(self):
            return utf8_char_array_to_py_compat_str(self._thisptr.code().c_str())

    property symbol:
        def __get__(self):
            return utf8_char_array_to_py_compat_str(self._thisptr.symbol().c_str())

    property fractionSymbol:
        def __get__(self):
            return utf8_char_array_to_py_compat_str(self._thisptr.fractionSymbol().c_str())

    property fractionsPerUnit:
        def __get__(self):
            return self._thisptr.fractionsPerUnit()
        
    def __str__(self):
        if not self._thisptr.empty():
            return utf8_char_array_to_py_compat_str(self._thisptr.name().c_str())
        else:
            return 'null currency'

    _lookup = dict([(cu.code, (cu.name, cu)) for cu in
                [USDCurrency(), EURCurrency(), GBPCurrency(),
                 JPYCurrency(), CHFCurrency(), AUDCurrency(),
                 DKKCurrency(), INRCurrency(), HKDCurrency(),
                 NOKCurrency(), NZDCurrency(), PLNCurrency(),
                 SEKCurrency(), SGDCurrency(), ZARCurrency()]])
    
    @classmethod
    def help(cls):
        tmp = [(k, v[0]) for k, v in cls._lookup.items()]
        tmp = map(list, zip(*tmp))
        return prettyprint(('Code', 'Currency'), 'ss', tmp)
    
    @classmethod
    def from_name(cls, code):
        return cls._lookup[code][1]

cdef class USDCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.USDCurrency()

cdef class EURCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.EURCurrency()

cdef class GBPCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.GBPCurrency()

cdef class JPYCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.JPYCurrency()

cdef class CHFCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.CHFCurrency()

cdef class AUDCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.AUDCurrency()

cdef class DKKCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.DKKCurrency()

cdef class INRCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.INRCurrency()

cdef class HKDCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.HKDCurrency()

cdef class NOKCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.NOKCurrency()

cdef class NZDCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.NZDCurrency()

cdef class PLNCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.PLNCurrency()

cdef class SEKCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.SEKCurrency()

cdef class SGDCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.SGDCurrency()

cdef class ZARCurrency(Currency):
    def __cinit__(self):
        self._thisptr = <_cu.Currency*> new _cu.ZARCurrency()
