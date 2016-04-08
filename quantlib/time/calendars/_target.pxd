from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/target.hpp' namespace 'QuantLib':
    cdef cppclass TARGET(Calendar):
        TARGET()
