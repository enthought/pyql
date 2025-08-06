from quantlib._handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.indexes._ibor_index cimport OvernightIndex

cdef extern from 'ql/indexes/ibor/fedfunds.hpp' namespace 'QuantLib' nogil:

    cdef cppclass FedFunds(OvernightIndex):
        FedFunds(Handle[YieldTermStructure]& h) except +
