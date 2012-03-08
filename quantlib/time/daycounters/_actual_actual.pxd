from quantlib.time._daycounter cimport DayCounter

cdef extern from 'ql/time/daycounters/actualactual.hpp' namespace 'QuantLib::ActualActual':
    cdef enum Convention:
        ISMA
        Bond
        ISDA
        Historical
        Actual365
        AFB
        Euro

cdef extern from 'ql/time/daycounters/actualactual.hpp' namespace 'QuantLib':

    cdef cppclass ActualActual(DayCounter):
        ActualActual(Convention)
