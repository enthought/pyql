"""Abstract base class for market observables"""
from quantlib.handle cimport static_pointer_cast
from quantlib._observable cimport Observable as QlObservable

cdef class Quote(Observable):
    """Abstract base class for market observables"""

    def __init__(self):
        raise ValueError(
            'This is an abstract class. Use SimpleQuote instead.'
        )

    property is_valid:
        def __get__(self):
            return self._thisptr.get().isValid()

    property value:
        def __get__(self):
            return self._thisptr.get().value()

    def __bool__(self):
        return self._thisptr.get().isValid()

    cdef shared_ptr[QlObservable] as_observable(self):
        return static_pointer_cast[QlObservable](self._thisptr)

    cdef inline Handle[_qt.Quote] handle(self):
        if not self._thisptr:
            return Handle[_qt.Quote]()
        else:
            return Handle[_qt.Quote](self._thisptr)

    @staticmethod
    cdef inline Handle[_qt.Quote] empty_handle():
        return Handle[_qt.Quote]()
