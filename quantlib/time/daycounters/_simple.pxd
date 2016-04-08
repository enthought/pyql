from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/daycounters/actual365fixed.hpp' namespace 'QuantLib':

    cdef cppclass Actual365Fixed(DayCounter):
        pass

cdef extern from 'ql/time/daycounters/actual360.hpp' namespace 'QuantLib':

    cdef cppclass Actual360(DayCounter):
        pass

cdef extern from 'ql/time/daycounters/business252.hpp' namespace 'QuantLib':

    cdef cppclass Business252(DayCounter):
        Business252(Calendar c)


cdef extern from 'ql/time/daycounters/one.hpp' namespace 'QuantLib':

    cdef cppclass OneDayCounter(DayCounter):
        pass

cdef extern from 'ql/time/daycounters/simpledaycounter.hpp' namespace 'QuantLib':

    cdef cppclass SimpleDayCounter(DayCounter):
        pass
