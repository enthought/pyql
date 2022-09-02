from .swap cimport Swap
from . cimport _fixedvsfloatingswap

cdef class FixedVsFloatingSwap(Swap):
    cdef inline _fixedvsfloatingswap.FixedVsFloatingSwap* get_ptr(self)
