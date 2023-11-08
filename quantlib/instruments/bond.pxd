from quantlib.instrument cimport Instrument
from . cimport _bond

cdef extern from "ql/instruments/bond.hpp" namespace "QuantLib::Bond::Price" nogil:
    cpdef enum Type:
        Dirty
        Clean

cdef class BondPrice:
    pass

cdef class Bond(Instrument):
    cdef inline _bond.Bond* as_ptr(self)
