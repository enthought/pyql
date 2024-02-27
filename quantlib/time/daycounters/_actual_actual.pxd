from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule


cdef extern from 'ql/time/daycounters/actualactual.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ActualActual(DayCounter):
        enum Convention:
            pass
        ActualActual(Convention c)
        ActualActual(Convention c, const Schedule& schedule)
