cimport _flat_forward as ffwd
from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr

cdef class Quote:
    cdef shared_ptr[ffwd.Quote]* _thisptr



cdef class YieldTermStructure:
    cdef ffwd.YieldTermStructure* _thisptr
    cdef ffwd.RelinkableHandle[ffwd.YieldTermStructure]* _relinkable_ptr
    cdef cbool relinkable


