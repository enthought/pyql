cimport _flat_forward as ffwd
from libcpp cimport bool as cbool

cdef class Quote:
    cdef ffwd.Quote* _thisptr



cdef class YieldTermStructure:
    cdef ffwd.YieldTermStructure* _thisptr
    cdef ffwd.RelinkableHandle[ffwd.YieldTermStructure]* _relinkable_ptr
    cdef cbool relinkable


