# distutils: language = c++
# distutils: libraries = QuantLib

"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'
from libcpp cimport bool

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()    

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

cdef extern from 'ql/currencies/america.hpp' namespace 'QuantLib':

    cdef cppclass USDCurrency(Currency):
        USDCurrency()

cdef extern from 'ql/currencies/europe.hpp' namespace 'QuantLib':

    cdef cppclass EURCurrency(Currency):
        EURCurrency()
