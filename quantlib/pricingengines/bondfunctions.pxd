from quantlib.instruments.bonds cimport Bond
from quantlib.time._date cimport Date

cimport quantlib.pricingengines._bondfunctions as _bf



cdef class BondFunctions:
    cpdef _bf.BondFunctions* _thisptr


    