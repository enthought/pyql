from quantlib.time.daycounter cimport DayCounter

cdef class Thirty360(DayCounter):
    pass

cdef extern from 'ql/time/daycounters/thirty360.hpp' namespace 'QuantLib::Thirty360':
    cpdef enum Convention:
         USA
         BondBasis
         European
         EurobondBasis
         Italian
         German
         ISMA
         ISDA
         NASD
