from quantlib.types cimport Time
from libcpp cimport bool
from libcpp.string cimport string
from ._date cimport Date, serial_type
from ._calendar cimport Calendar


cdef extern from 'ql/time/daycounter.hpp' namespace 'QuantLib':

    cdef cppclass DayCounter:
        DayCounter() nogil
        DayCounter(const DayCounter&) nogil
        bool empty()
        string name() except +
        serial_type dayCount(Date&, Date&) except +
        Time yearFraction(Date&, Date&, Date&, Date&) except +
        bool operator==(DayCounter&)
        bool operator!=(DayCounter&)
