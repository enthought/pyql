include '../../../types.pxi'
from libcpp cimport bool

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.termstructures._vol_term_structure cimport VolatilityTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/blackvoltermstructure.hpp' namespace 'QuantLib':

    cdef cppclass BlackVolTermStructure(VolatilityTermStructure):
        BlackVolTermStructure(
            Calendar& cal,
            BusinessDayConvention bdc,
            DayCounter& dc
        )
        Volatility blackVol(const Date& maturity,
                            Real strike,
                            bool extrapolate=false)
        Volatility blackVol(Time maturity,
                            Real strike,
                            bool extrapolate=false)


    cdef cppclass BlackVolatilityTermStructure(BlackVolTermStructure):
        BlackVolatilityTermStructure(BusinessDayConvention bdc, #=Following,
                                     const DayCounter& dc) #=DayCounter())
        BlackVolatilityTermStructure(const Date& referenceDate,
                                     const Calendar& cal, # = Calendar(),
                                     BusinessDayConvention bdc, # = Following,
                                     const DayCounter& dc) # = DayCounter())
        BlackVolatilityTermStructure(Natural settlementDays,
                                     const Calendar& cal,
                                     BusinessDayConvention bdc, # = Following,
                                     const DayCounter& dc) # = DayCounter())
