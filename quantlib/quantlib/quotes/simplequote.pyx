
from quantlib.quote cimport Quote
from quantlib.handle cimport shared_ptr

cimport quantlib._quote as _qt
cimport quantlib.quotes._simplequote as _sqt

cdef class SimpleQuote(Quote):

    def __init__(self, float value=0.0):
        self._thisptr = new shared_ptr[_qt.Quote](new _sqt.SimpleQuote(value))
        
    def __str__(self):
        return 'Simple Quote: %f' % self._thisptr.get().value()

    property value:
        def __get__(self):
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None

        def __set__(self, float value):
            (<_sqt.SimpleQuote*>self._thisptr.get()).setValue(value)
