from ..option cimport Option
from . cimport _oneassetoption as _oa

cdef class OneAssetOption(Option):
    cdef inline _oa.OneAssetOption* as_ptr(self) noexcept nogil
