include '../types.pxi'
from quantlib.handle cimport shared_ptr
from ._vanillaswap cimport VanillaSwap
from ._option cimport Option
from ._exercise cimport Exercise

cdef extern from 'ql/instruments/swaption.hpp' namespace 'QuantLib':
    cdef cppclass Settlement:
        enum Type:
            Physical
            Cash

    cdef cppclass Swaption(Option):
        Swaption(const shared_ptr[VanillaSwap]& swap,
                 const shared_ptr[Exercise]& exercise,
                 Settlement.Type delivery)# = Settlement.Physical)
