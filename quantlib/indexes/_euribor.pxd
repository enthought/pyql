# distutils: language = c++
# distutils: libraries = QuantLib

from quantlib.handle cimport Handle
cimport quantlib.termstructures._yield_term_structure as _yts
# cimport quantlib.indexes._ibor_index as _ib
from quantlib.indexes._ibor_index cimport IborIndex

cdef extern from 'ql/indexes/ibor/euribor.hpp' namespace 'QuantLib':

    cdef cppclass Euribor(IborIndex):
        pass
    
    cdef cppclass Euribor6M(Euribor):
        Euribor6M(Handle[_yts.YieldTermStructure]& yc)
