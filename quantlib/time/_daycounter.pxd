include '../types.pxi'

from libcpp cimport bool
from libcpp.string cimport string
from _date cimport Date
from _calendar cimport Calendar


cdef extern from 'ql/time/daycounter.hpp' namespace 'QuantLib':

    cdef cppclass DayCounter:
        DayCounter()
        DayCounter(const DayCounter&)
        bool empty()
        string name()
        BigInteger dayCount(Date&, Date&)
        Time yearFraction(Date&, Date&, Date&, Date&)
