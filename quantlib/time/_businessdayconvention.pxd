from libcpp.string cimport string

cdef extern from "ql/time/businessdayconvention.hpp" namespace "QuantLib":
    cdef enum BusinessDayConvention:
        Following
        ModifiedFollowing
        Preceding
        ModifiedPreceding
        Unadjusted
        HalfMonthModifiedFollowing
        Nearest

cdef extern from "<sstream>" namespace "std":
    cdef cppclass stringstream:
        stringstream& operator<<(BusinessDayConvention)
        string str()
