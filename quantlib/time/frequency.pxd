from libcpp.string cimport string

cdef extern from 'ql/time/frequency.hpp' namespace "QuantLib" nogil:
    cpdef enum Frequency:
        """Frequency of events

        Attributes
        ----------
        NoFrequency
            null frequency
        Once
            only once, e.g., a zero-coupon
        Annual
            once a year
        Semiannual
            twice a year
        EveryFourthMonth
            every fourth month
        Quarterly
            every third month
        Bimonthly
            every second month
        Monthly
            once a month
        EveryFourthWeek
            every fourth week
        Biweekly
            every second week
        Weekly
            once a week
        Daily
            once a day
        OtherFrequency
            some other unknown frequency
        """
        NoFrequency
        Once
        Annual
        Semiannual
        EveryFourthMonth
        Quarterly
        Bimonthly
        Monthly
        EveryFourthWeek
        Biweekly
        Weekly
        Daily
        OtherFrequency

cdef extern from "<sstream>" namespace "std":
    cdef cppclass stringstream:
        stringstream& operator<<(Frequency)
        string str()
