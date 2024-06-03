from ._observable cimport Observable as QlObservable

cdef class Observable:
    cdef shared_ptr[QlObservable] as_observable(self) noexcept nogil:
        pass

cdef class Observer:
    def __init__(self, object callback):
        self._thisptr = PyObserver(callback)
    def register_with(self, Observable obj not None):
        self._thisptr.registerWith(obj.as_observable())

    def unregister_with(self, Observable obj not None):
        self._thisptr.unregisterWith(obj.as_observable())
