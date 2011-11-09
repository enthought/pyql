cimport quantlib._index as _in
from quantlib.handle cimport shared_ptr

cdef class Index:
    cdef shared_ptr[_in.Index]* _thisptr
    
