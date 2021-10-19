from .._calendar cimport Calendar

cdef extern from 'ql/time/calendars/poland.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Poland(Calendar):
        Poland()
