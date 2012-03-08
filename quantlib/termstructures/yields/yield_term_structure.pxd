cimport _flat_forward as _ff
from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr, RelinkableHandle

cdef class YieldTermStructure:
    cdef shared_ptr[_ff.YieldTermStructure]* _thisptr
    cdef RelinkableHandle[_ff.YieldTermStructure]* _relinkable_ptr
    cdef cbool relinkable
