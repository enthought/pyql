include '../types.pxi'
from libcpp cimport bool

cdef extern from 'ql/time/frequency.hpp' namespace "QuantLib":
    cdef enum Frequency:
        NoFrequency      = -1 # null frequency
        Once             = 0  # only once, e.g., a zero-coupon
        Annual           = 1  # once a year
        Semiannual       = 2  # twice a year
        EveryFourthMonth = 3  # every fourth month
        Quarterly        = 4  # every third month
        Bimonthly        = 6  # every second month
        Monthly          = 12 # once a month
        EveryFourthWeek  = 13 # every fourth week
        Biweekly         = 26 # every second week
        Weekly           = 52 # once a week
        Daily            = 365 # once a day
        OtherFrequency   = 999 # some other unknown frequency

cdef extern from 'ql/time/timeunit.hpp' namespace "QuantLib":
    cdef enum TimeUnit:
        Days,
        Weeks,
        Months,
        Years

cdef extern from 'ql/time/period.hpp' namespace "QuantLib":

    cdef cppclass Period:

        Period()
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

    Period mult_op 'operator*'(Period& p, Integer i) except +
    Period sub_op 'operator-'(Period& p1, Period& p2)
    Period add_op 'operator+'(Period& p1, Period& p2)
    bool eq_op 'operator=='(Period& p1, Period& p2)
    bool neq_op 'operator!='(Period& p1, Period& p2)
    bool g_op 'operator>'(Period& p1, Period& p2)
    bool geq_op 'operator>='(Period& p1, Period& p2)
    bool l_op 'operator<'(Period& p1, Period& p2)
    bool leq_op 'operator<='(Period& p1, Period& p2)

    Real years(const Period& p) except +
    Real months(const Period& p) except +
    Real weeks(const Period& p) except +
    Real days(const Period& p) except +
