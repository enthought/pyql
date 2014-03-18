from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/switzerland.hpp' namespace 'QuantLib':
    cdef cppclass Switzerland(Calendar):
        Switzerland()

