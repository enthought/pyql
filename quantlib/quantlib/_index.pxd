# distutils: language = c++
# distutils: libraries = QuantLib

include 'types.pxi'

from libcpp cimport bool

from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

cdef extern from 'ql/index.hpp' namespace 'QuantLib':

    cdef cppclass Index:
        Index()
        string name()
        Calendar fixingCalendar()
        bool isValidFixingDate(Date& fixingDate)
        Real fixing(Date& fixingDate, bool forecastTodaysFixing)
        addFixing(Date& fixingDate, Real fixing, bool forceOverwrite)
        
