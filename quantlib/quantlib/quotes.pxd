cimport _quote as qt
from quantlib.handle cimport shared_ptr

cdef class Quote:
    cdef shared_ptr[qt.Quote]* _thisptr
