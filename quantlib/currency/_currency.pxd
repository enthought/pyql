"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string


cdef extern from 'ql/currency.hpp' namespace 'QuantLib':

    cdef cppclass Currency:
        Currency()
        string name()
        string code()
        Integer numericCode()
        string symbol()
        string fractionSymbol()
        Integer fractionsPerUnit()
        #Rounding& rounding()
    
        string format()
        bool empty()

cdef extern from 'ql/currencies/all.hpp' namespace 'QuantLib':

    cdef cppclass USDCurrency(Currency):
        USDCurrency()

    cdef cppclass EURCurrency(Currency):
        EURCurrency()

    cdef cppclass GBPCurrency(Currency):
        GBPCurrency()

    cdef cppclass JPYCurrency(Currency):
        JPYCurrency()
        
    cdef cppclass CHFCurrency(Currency):
        CHFCurrency()

    cdef cppclass AUDCurrency(Currency):
        AUDCurrency()

    cdef cppclass DKKCurrency(Currency):
        DKKCurrency()

    cdef cppclass INRCurrency(Currency):
        INRCurrency()

    cdef cppclass HKDCurrency(Currency):
        HKDCurrency()

    cdef cppclass NOKCurrency(Currency):
        NOKCurrency()

    cdef cppclass NZDCurrency(Currency):
        NZDCurrency()

    cdef cppclass PLNCurrency(Currency):
        PLNCurrency()

    cdef cppclass SEKCurrency(Currency):
        SEKCurrency()

    cdef cppclass SGDCurrency(Currency):
        SGDCurrency()

    cdef cppclass ZARCurrency(Currency):
        ZARCurrency()
