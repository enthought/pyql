from quantlib.time._daycounter cimport DayCounter
from quantlib.time._date cimport Date

cdef extern from 'ql/time/daycounters/thirty360.hpp' namespace 'QuantLib':

    cdef cppclass Thirty360(DayCounter):
        enum Convention:
            pass
        Thirty360(Convention c)
        Thirty360(Convention c, Date d)
