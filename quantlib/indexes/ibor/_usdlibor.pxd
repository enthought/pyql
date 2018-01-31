from quantlib.handle cimport Handle
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.indexes.ibor._libor cimport Libor
from quantlib.time._period cimport Period


cdef extern from 'ql/indexes/ibor/usdlibor.hpp' namespace 'QuantLib':

    cdef cppclass USDLibor(Libor):
        USDLibor(Period& tenor,
                Handle[_yts.YieldTermStructure]& h) except +

