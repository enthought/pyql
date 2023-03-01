include '../types.pxi'
from libcpp cimport bool
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time.businessdayconvention cimport BusinessDayConvention

cdef extern from 'ql/termstructures/voltermstructure.hpp' namespace 'QuantLib' nogil:
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
        DayCounter dayCounter() const
        # date/time conversion
        Time timeFromReference(const Date& date) const;
        # the latest date for which the curve can return values
        Date maxDate() const
        # the latest time for which the curve can return values
        # Time maxTime() const;
        # the date at which discount = 1.0 and/or variance = 0.0
        Date& referenceDate() const
        # the calendar used for reference and/or option date calculation
        Calendar calendar() const;
        # the settlementDays used for reference date calculation
        Natural settlementDays() const
        Date optionDateFromTenor(const Period&) const
        void enableExtrapolation(bool)
        void disableExtrapolation(bool)
        bool allowsExtrapolation() const
