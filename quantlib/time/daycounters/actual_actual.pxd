from quantlib.time.daycounter cimport DayCounter


cdef class ActualActual(DayCounter):
    pass

cdef extern from 'ql/time/daycounters/actualactual.hpp' namespace 'QuantLib::ActualActual':
    cpdef enum Convention:
        ISMA
        Bond
        ISDA
        Historical
        Actual365
        AFB
        Euro
