from ._observable cimport PyObserver, Observable as QlObservable
from .handle cimport shared_ptr

cdef class Observable:
    cdef shared_ptr[QlObservable] as_observable(self) noexcept nogil

cdef class Observer:
    cdef PyObserver _thisptr
