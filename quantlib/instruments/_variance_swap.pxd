from ._instrument cimport Instrument
from quantlib.time._date cimport Date
from libcpp cimport bool

include '../types.pxi'

# Variance swap
# warning This class does not manage seasoned variance swaps.
# ingroup instruments

cdef extern from 'ql/position.hpp' namespace 'QuantLib::Position':
    cdef enum Type:
        Long,
        Short

cdef extern from 'ql/instruments/varianceswap.hpp' namespace 'QuantLib':

    cdef cppclass VarianceSwap(Instrument):

        VarianceSwap(Type position,
                     Real strike,
                     Real notional,
                     Date& startDate,
                     Date& maturityDate) except +
        bool isExpired()
        Real strike()
        Type position()
        Date startDate()
        Date maturityDate()
        Real notional()
        Real variance()
