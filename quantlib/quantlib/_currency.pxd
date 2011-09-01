# distutils: language = c++
# distutils: libraries = QuantLib

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
