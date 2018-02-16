include '../types.pxi'
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._businessdayconvention cimport BusinessDayConvention

cdef extern from 'ql/termstructures/voltermstructure.hpp' namespace 'QuantLib':
    cdef cppclass VolatilityTermStructure:
        VolatilityTermStructure(BusinessDayConvention bdc,
                                const DayCounter& dc) # = DayCounter()
        #initialize with a fixed reference date
        VolatilityTermStructure(const Date& referenceDate,
                                const Calendar& cal,
                                BusinessDayConvention bdc,
                                const DayCounter& dc) # = DayCounter()
        #calculate the reference date based on the global evaluation date
        VolatilityTermStructure(Natural settlementDays,
                                const Calendar& cal,
                                BusinessDayConvention bdc,
                                const DayCounter& dc) # = DayCounter()
