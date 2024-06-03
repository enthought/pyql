from quantlib.types cimport Natural, Time
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter

cdef extern from 'ql/termstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass TermStructure:
        TermStructure(DayCounter& dc) except +
        DayCounter dayCounter()
        Time timeFromReference(Date& d)
        Date referenceDate()
        Date maxDate()
        Time maxTime()
        Calendar calendar()
        Natural settlementDays() except +
