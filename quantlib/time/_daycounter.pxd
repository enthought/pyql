include '../types.pxi'

from libcpp cimport bool
from libcpp.string cimport string
from _date cimport Date
from _calendar cimport Calendar


cdef extern from 'ql/time/daycounter.hpp' namespace 'QuantLib':

    cdef cppclass DayCounter:
        DayCounter()
        bool empty()
        string name()
        BigInteger dayCount(Date&, Date&)
        Time yearFraction(Date&, Date&, Date&, Date&)

cdef extern from 'ql/time/daycounters/thirty360.hpp' namespace 'QuantLib':

    cdef cppclass Thirty360(DayCounter):
        pass

cdef extern from 'ql/time/daycounters/actual360.hpp' namespace 'QuantLib':

    cdef cppclass Actual360(DayCounter):
        pass

cdef extern from 'ql/time/daycounters/actual365fixed.hpp' namespace 'QuantLib':

    cdef cppclass Actual365Fixed(DayCounter):
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

