cimport quantlib._quote as _qt
from quantlib._handle cimport Handle
from quantlib.ext cimport shared_ptr
from quantlib.observable cimport Observable

cdef class Quote(Observable):
    cdef shared_ptr[_qt.Quote] _thisptr
    cdef Handle[_qt.Quote] handle(self)
    @staticmethod
    cdef Handle[_qt.Quote] empty_handle()
