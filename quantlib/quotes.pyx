from quantlib.handle cimport shared_ptr
cimport quantlib._quote as _qt

cdef class Quote:

    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self):
        raise ValueError(
            'This is an abstract class. Use SimpleQuote instaed.'
        )

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    property is_valid:
        def __get__(self):
            return self._thisptr.get().isValid()

    property value:
        def __get__(self):
            # TODO: check if we can get rid of this test,
            # now that we catch c++ exceptions
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None

cdef class SimpleQuote(Quote):

    def __init__(self, float value=0.0):
        self._thisptr = new shared_ptr[_qt.Quote](new _qt.SimpleQuote(value))

    def __str__(self):
        return 'Simple Quote: %f' % self._thisptr.get().value()

    property value:
        def __get__(self):
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None

        def __set__(self, float value):
            (<_qt.SimpleQuote*>self._thisptr.get()).setValue(value)
