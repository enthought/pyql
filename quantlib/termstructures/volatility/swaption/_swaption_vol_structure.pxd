include '../../../types.pxi'
from libcpp cimport bool
from quantlib.time._date cimport Date, Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.termstructures._vol_term_structure cimport VolatilityTermStructure

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvolstructure.hpp' namespace 'QuantLib':
    cdef cppclass SwaptionVolatilityStructure(VolatilityTermStructure):
        SwaptionVolatilityStructure(BusinessDayConvention bdc,
                                    const DayCounter& dc) nogil#= DayCounter())
        # initialize with a fixed reference date
        SwaptionVolatilityStructure(const Date& referenceDate,
                                    const Calendar& calendar,
                                    BusinessDayConvention bdc,
                                    const DayCounter& dc) nogil#= DayCounter())
        # calculate the reference date based on the global evaluation date
        SwaptionVolatilityStructure(Natural settlementDays,
                                    const Calendar&,
                                    BusinessDayConvention bdc,
                                    const DayCounter& dc) nogil# = DayCounter())
        # returns the volatility for a given option tenor and swap tenor
        Volatility volatility(const Period& optionTenor,
                              const Period& swapTenor,
                              Rate strike,
                              bool extrapolate) # = false)
        # returns the volatility for a given option date and swap tenor
        Volatility volatility(const Date& optionDate,
                              const Period& swapTenor,
                              Rate strike,
                              bool extrapolate) # = false) const
        # returns the volatility for a given option time and swap tenor
        Volatility volatility(Time optionTime,
                              const Period& swapTenor,
                              Rate strike,
                              bool extrapolate)  # = false)
        # returns the volatility for a given option tenor and swap length
        Volatility volatility(const Period& optionTenor,
                              Time swapLength,
                              Rate strike,
                              bool extrapolate) # = false)
        # returns the volatility for a given option date and swap length
        Volatility volatility(const Date& optionDate,
                              Time swapLength,
                              Rate strike,
                              bool extrapolate) # = false)
        # returns the volatility for a given option time and swap length
        Volatility volatility(Time optionTime,
                              Time swapLength,
                              Rate strike,
                              bool extrapolate) # = false)
