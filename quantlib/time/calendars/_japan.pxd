from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/japan.hpp' namespace 'QuantLib':
    cdef cppclass Japan(Calendar):
        Japan()

