# distutils: language = c++
# distutils: libraries = QuantLib

from quantlib.handle cimport Handle
cimport quantlib.termstructures.yields._flat_forward as _ff
# cimport quantlib.indexes._ibor_index as _ib
from quantlib.indexes._ibor_index cimport IborIndex

cdef extern from 'ql/indexes/ibor/euribor.hpp' namespace 'QuantLib':

    cdef cppclass Euribor(IborIndex):
        pass
    
    cdef cppclass Euribor6M(Euribor):
        Euribor6M(Handle[_ff.YieldTermStructure]& yc)
