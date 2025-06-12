from quantlib._handle cimport Handle
from quantlib.time._date cimport Date
from .._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/termstructures/yield/impliedtermstructure.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ImpliedTermStructure(YieldTermStructure):
        ImpliedTermStructure(const Handle[YieldTermStructure]&,
                             const Date& referenceDate)
