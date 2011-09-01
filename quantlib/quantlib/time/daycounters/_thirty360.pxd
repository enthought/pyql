from quantlib.time._daycounter cimport DayCounter

cdef extern from 'ql/time/daycounters/thirty360.hpp' \
        namespace 'QuantLib::Thirty360':

    cdef enum Convention:
        USA
        BondBasis
        European
        EurobondBasis
        Italian

cdef extern from 'ql/time/daycounters/thirty360.hpp' namespace 'QuantLib':

    cdef cppclass Thirty360(DayCounter):
        Thirty360(Convention c)
