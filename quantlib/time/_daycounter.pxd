include '../types.pxi'

from libcpp cimport bool
from libcpp.string cimport string
from _date cimport Date, serial_type
from _calendar cimport Calendar


cdef extern from 'ql/time/daycounter.hpp' namespace 'QuantLib':

    cdef cppclass DayCounter:
        DayCounter()
        DayCounter(const DayCounter&)
        bool empty()
        string name() except +
        BigInteger dayCount(Date&, Date&) except +
        Time yearFraction(Date&, Date&, Date&, Date&) except +
        string name()
        serial_type dayCount(Date&, Date&)
        Time yearFraction(Date&, Date&, Date&, Date&)
