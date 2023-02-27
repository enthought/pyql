from quantlib.time._daycounter cimport DayCounter



cdef extern from 'ql/time/daycounters/actualactual.hpp' namespace 'QuantLib':
    cdef cppclass ActualActual(DayCounter):
        enum Convention:
            pass
        ActualActual(Convention)
