from quantlib.types cimport Real
from quantlib.models.shortrate._onefactor_model cimport OneFactorModel
from quantlib._handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/models/shortrate/onefactormodels/blackkarasinski.hpp' namespace 'QuantLib':

    cdef cppclass BlackKarasinski(OneFactorModel):

        BlackKarasinski(Handle[YieldTermStructure] termStructure, Real a, Real sigma) except +
