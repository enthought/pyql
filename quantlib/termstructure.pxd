from . cimport _termstructure as _ts
from quantlib.observable cimport Observable
from quantlib.handle cimport shared_ptr
from quantlib._observable cimport Observable as QlObservable

cdef class TermStructure(Observable):
    cdef shared_ptr[_ts.TermStructure] _thisptr
    cdef inline _ts.TermStructure* as_ptr(self) except NULL
    cdef shared_ptr[QlObservable] as_observable(self) noexcept nogil
