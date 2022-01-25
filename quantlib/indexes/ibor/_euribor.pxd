from quantlib.handle cimport Handle
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._period cimport Period

cdef extern from 'ql/indexes/ibor/euribor.hpp' namespace 'QuantLib':

    cdef cppclass Euribor(IborIndex):
        Euribor(  Period& tenor,
                  Handle[_yts.YieldTermStructure]& h) except +

    cdef cppclass Euribor6M(Euribor):
        Euribor6M(Handle[_yts.YieldTermStructure]& yc)

    cdef cppclass Euribor3M(Euribor):
        Euribor3M(Handle[_yts.YieldTermStructure]& yc)
