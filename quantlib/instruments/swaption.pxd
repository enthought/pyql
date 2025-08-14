from . cimport _swaption
from ..option cimport Option

cdef extern from "ql/instruments/swaption.hpp" namespace "QuantLib::Settlement":
    cpdef enum class Method "QuantLib::Settlement::Method":
        PhysicalOTC
        PhysicalCleared
        CollateralizedCashPrice
        ParYieldCurve

    cpdef enum class Type "QuantLib::Settlement::Type":
        Physical
        Cash

cdef class Swaption(Option):
    cdef inline _swaption.Swaption* get_swaption(self) noexcept nogil
