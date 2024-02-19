from libcpp.string cimport string

cdef extern from 'ql/time/frequency.hpp' namespace "QuantLib" nogil:
    cpdef enum Frequency:
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

cdef extern from "<sstream>" namespace "std":
    cdef cppclass stringstream:
        stringstream& operator<<(Frequency)
        string str()
