include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string

from frequency cimport Frequency

cdef extern from 'ql/time/timeunit.hpp' namespace "QuantLib":
    cdef enum TimeUnit:
        Days,
        Weeks,
        Months,
        Years

cdef extern from 'ql/time/period.hpp' namespace "QuantLib":

    cdef cppclass Period:

        Period()
        Period(Period&)
        Period (Integer n, TimeUnit units)
        Period (Frequency f)

        Integer length ()
        TimeUnit units ()
        Frequency frequency ()
        void normalize ()

        # unsupported operators
        # fixme : adding an except + here cause Cython to generate wrong code
        Period& i_add 'operator+=' (Period &)
        Period& i_sub 'operator-=' (Period &)
        Period& i_div 'operator/=' (Integer)

    Period operator*(Integer i) except +
    Period operator-(Period& p2) except +
    Period operator+(Period& p2) except +
    bool operator==(Period& p1)
    bool operator!=(Period& p1)
    bool operator>(Period& p1)
    bool operator>=(Period& p1)
    bool operator<(Period& p1)
    bool operator<=(Period&)

    Real years(const Period& p) except +
    Real months(const Period& p) except +
    Real weeks(const Period& p) except +
    Real days(const Period& p) except +

cdef extern from 'ql/utilities/dataparsers.hpp' namespace "QuantLib::PeriodParser":
    Period parse(string& str) except +

cdef extern from "ql/time/period.hpp" namespace "QuantLib::detail":
    cdef cppclass long_period_holder:
        pass
    cdef cppclass short_period_holder:
        pass

cdef extern from "ql/time/period.hpp" namespace "QuantLib::io":
    cdef short_period_holder short_period(const Period&)
    cdef long_period_holder long_period(const Period&)

cdef extern from "<sstream>" namespace "std":
    cdef cppclass stringstream:
        stringstream& operator<<(long_period_holder)
        stringstream& operator<<(short_period_holder)
        stringstream& operator<<(string)
        string str()
