from quantlib.types cimport Natural, Real, Time, Volatility
from libcpp cimport bool

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from ..._vol_term_structure cimport VolatilityTermStructure
from quantlib.time.businessdayconvention cimport BusinessDayConvention
cdef extern from 'ql/termstructures/volatility/equityfx/localvoltermstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass LocalVolTermStructure(VolatilityTermStructure):
        # Constructors
        #    See the TermStructure documentation for issues regarding
        #    constructors.
        #
        # default constructor
        # warning term structures initialized by means of this
        #     constructor must manage their own reference date
        #     by overriding the referenceDate() method.
        LocalVolTermStructure(BusinessDayConvention bdc, #= Following,
                              DayCounter& dc)
        # initialize with a fixed reference date
        LocalVolTermStructure(Date& referenceDate,
                              Calendar& cal, #= Calendar(),
                              BusinessDayConvention bdc, #= Following,
                              DayCounter& dc)
        # calculate the reference date based on the global evaluation date
        LocalVolTermStructure(Natural settlementDays,
                              Calendar& cal,
                              BusinessDayConvention bdc, #= Following,
                              DayCounter& dc)

        Volatility localVol(const Date& d,
                            Real underlyingLevel,
                            bool extrapolate = false) const
        Volatility localVol(Time t,
                            Real underlyingLevel,
                            bool extrapolate = false) const
