from quantlib._defines cimport QL_NULL_REAL
from . cimport _simplequote as _sq

cdef class SimpleQuote(Quote):
    def __init__(self, double value=QL_NULL_REAL):
        self._thisptr.reset(new _sq.SimpleQuote(value))

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
            (<_sq.SimpleQuote*>self._thisptr.get()).setValue(value)

    def reset(self):
        (<_sq.SimpleQuote*>self._thisptr.get()).reset()
