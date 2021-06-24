from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.indexes._ibor_index cimport OvernightIndex

cdef extern from 'ql/indexes/ibor/eonia.hpp' namespace 'QuantLib':

    cdef cppclass Eonia(OvernightIndex):
        Eonia(Handle[YieldTermStructure]& h) except +
