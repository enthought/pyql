from ..bond cimport Bond

cdef extern from 'ql/cashflows/cpicoupon.hpp' namespace 'QuantLib::CPI':
    cpdef enum InterpolationType:
        AsIndex
        Flat
        Linear

cdef class CPIBond(Bond):
    pass
