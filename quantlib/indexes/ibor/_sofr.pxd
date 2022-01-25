from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.indexes._ibor_index cimport OvernightIndex

cdef extern from 'ql/indexes/ibor/sofr.hpp' namespace 'QuantLib':

    cdef cppclass Sofr(OvernightIndex):
        Sofr(Handle[YieldTermStructure]& h) except +
