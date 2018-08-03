from quantlib.handle cimport shared_ptr, static_pointer_cast
cimport quantlib._quote as _qt
from quantlib._observable cimport Observable as QlObservable

cdef class Quote(Observable):

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

    cdef shared_ptr[QlObservable] as_observable(self):
        return static_pointer_cast[QlObservable](self._thisptr)

cdef class SimpleQuote(Quote):

    def __init__(self, value=None):
        if value is None:
            self._thisptr = shared_ptr[_qt.Quote](new _qt.SimpleQuote())
        else:
            self._thisptr = shared_ptr[_qt.Quote](new _qt.SimpleQuote(<double>value))

    def __str__(self):
        if self._thisptr.get().isValid():
            return 'Simple Quote: %f' % self._thisptr.get().value()
        else:
            return 'Empty Quote'

    def __repr__(self):
        try:
            return "SimpleQuote({0})".format(self._thisptr.get().value())
        except RuntimeError:
            return "SimpleQuote()"

    property value:
        def __get__(self):
            return self._thisptr.get().value()

        def __set__(self, double value):
            (<_qt.SimpleQuote*>self._thisptr.get()).setValue(value)

    def reset(self):
        (<_qt.SimpleQuote*>self._thisptr.get()).reset()
