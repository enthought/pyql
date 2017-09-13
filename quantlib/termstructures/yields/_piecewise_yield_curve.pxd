include '../../types.pxi'

from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.yields._rate_helpers cimport RateHelper

cdef extern from 'ql/termstructures/yield/bootstraptraits.hpp' namespace 'QuantLib':

    cdef cppclass Discount:
        pass

    cdef cppclass ZeroYield:
        pass

    cdef cppclass ForwardRate:
        pass

cdef extern from 'ql/termstructures/yield/piecewiseyieldcurve.hpp' namespace 'QuantLib':
    cdef cppclass PiecewiseYieldCurve[T, I](YieldTermStructure):
        PiecewiseYieldCurve(Date& referenceDate,
                            vector[shared_ptr[RateHelper]]& instruments,
                            DayCounter& dayCounter,
                            Real accuracy) except +
        PiecewiseYieldCurve(Natural settlementDays,
                            Calendar& calendar,
                            vector[shared_ptr[RateHelper]]& instruments,
                            DayCounter& dayCounter,
                            Real accuracy) except +
        vector[Time]& times() except +
        vector[Date]& dates() except +
        vector[Real]& data() except +
