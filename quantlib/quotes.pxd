cimport _quote as _qt
from quantlib.handle cimport shared_ptr
from quantlib.observable cimport Observable

cdef class Quote(Observable):
    cdef shared_ptr[_qt.Quote] _thisptr

cdef class SimpleQuote(Quote):
    pass
