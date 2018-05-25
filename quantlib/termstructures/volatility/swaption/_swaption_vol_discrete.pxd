include '../../../types.pxi'

from libcpp.vector cimport vector
from quantlib.time._date cimport Date, Period
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.termstructures.volatility.swaption._swaption_vol_structure \
    cimport SwaptionVolatilityStructure

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvoldiscrete.hpp' namespace 'QuantLib':
    cdef cppclass SwaptionVolatilityDiscrete(SwaptionVolatilityStructure):
        # floating reference date, floating market data
        SwaptionVolatilityDiscrete(
            const vector[Period]& optionTenors,
            const vector[Period]& swapTenors,
            Natural settlementDays,
            const Calendar& cal,
            BusinessDayConvention bdc,
            const DayCounter& dc)
        SwaptionVolatilityDiscrete(
            const vector[Period]& optionTenors,
            const vector[Period]& swapTenors,
            const Date& referenceDate,
            const Calendar& cal,
            BusinessDayConvention bdc,
            const DayCounter& dc)
        SwaptionVolatilityDiscrete(
            const vector[Date]& optionDate,
            const vector[Date]& swapDate,
            const Date& referenceDate,
            const Calendar& cal,
            BusinessDayConvention bdc,
            const DayCounter& dc)
        const vector[Period]& optionTenors()
        const vector[Date]& optionDates()
        const vector[Time]& optionTimes()
        const vector[Period]& swapTenors()
        const vector[Time]& swapLengths()
