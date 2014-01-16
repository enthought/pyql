"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _currency

cdef class Currency:
    cdef _currency.Currency *_thisptr

cdef class USDCurrency(Currency):
    pass

cdef class EURCurrency(Currency):
    pass

cdef class GBPCurrency(Currency):
    pass

cdef class JPYCurrency(Currency):
    pass

cdef class CHFCurrency(Currency):
    pass

cdef class AUDCurrency(Currency):
    pass

cdef class DKKCurrency(Currency):
    pass

cdef class INRCurrency(Currency):
    pass

cdef class HKDCurrency(Currency):
    pass

cdef class NOKCurrency(Currency):
    pass

cdef class NZDCurrency(Currency):
    pass

cdef class PLNCurrency(Currency):
    pass

cdef class SEKCurrency(Currency):
    pass

cdef class SGDCurrency(Currency):
    pass

cdef class ZARCurrency(Currency):
    pass
