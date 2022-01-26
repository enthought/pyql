include '../../../types.pxi'
from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date, Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.termstructures._vol_term_structure cimport VolatilityTermStructure
from .._smilesection cimport SmileSection
from quantlib.termstructures.volatility._volatilitytype cimport VolatilityType

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvolstructure.hpp' namespace 'QuantLib' nogil:
    cdef cppclass SwaptionVolatilityStructure(VolatilityTermStructure):
        SwaptionVolatilityStructure(BusinessDayConvention bdc,
                                    const DayCounter& dc) #= DayCounter())
        # initialize with a fixed reference date
        SwaptionVolatilityStructure(const Date& referenceDate,
                                    const Calendar& calendar,
                                    BusinessDayConvention bdc,
                                    const DayCounter& dc) #= DayCounter())
        # calculate the reference date based on the global evaluation date
        SwaptionVolatilityStructure(Natural settlementDays,
                                    const Calendar&,
                                    BusinessDayConvention bdc,
                                    const DayCounter& dc) # = DayCounter())
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
        # returns the Black variance for a given option tenor and swap tenor
        Real blackVariance(const Period& optionTenor,
                           const Period& swapTenor,
                           Rate strike,
                           bool extrapolate) const # = false)
        # returns the Black variance for a given option date and swap tenor
        Real blackVariance(const Date& optionDate,
                           const Period& swapTenor,
                           Rate strike,
                           bool extrapolate) const # = false
        # returns the Black variance for a given option time and swap tenor
        Real blackVariance(Time optionTime,
                           const Period& swapTenor,
                           Rate strike,
                           bool extrapolate) const # = false
        # returns the Black variance for a given option tenor and swap length
        Real blackVariance(const Period& optionTenor,
                           Time swapLength,
                           Rate strike,
                           bool extrapolate) const # = false
        # returns the Black variance for a given option date and swap length
        Real blackVariance(const Date& optionDate,
                           Time swapLength,
                           Rate strike,
                           bool extrapolate) const # = false
        # returns the Black variance for a given option time and swap length
        Real blackVariance(Time optionTime,
                           Time swapLength,
                           Rate strike,
                           bool extrapolate) const # = false

        # returns the shift for a given option tenor and swap tenor
        Real shift(const Period& optionTenor,
                   const Period& swapTenor,
                   bool extrapolate) const # = false
        # returns the shift for a given option date and swap tenor
        Real shift(const Date& optionDate,
                   const Period& swapTenor,
                   bool extrapolate) const # = false
        # returns the shift for a given option time and swap tenor
        Real shift(Time optionTime,
                   const Period& swapTenor,
                   bool extrapolate) const # = false
        # returns the shift for a given option tenor and swap length
        Real shift(const Period& optionTenor,
                   Time swapLength,
                   bool extrapolate) const # = false
        # returns the shift for a given option date and swap length
        Real shift(const Date& optionDate,
                   Time swapLength,
                   bool extrapolate) const # = false
        # returns the shift for a given option time and swap length
        Real shift(Time optionTime,
                   Time swapLength,
                   bool extrapolate) const # = false

        # returns the smile for a given option tenor and swap tenor
        shared_ptr[SmileSection] smileSection(const Period& optionTenor,
                                              const Period& swapTenor,
                                              bool extr) const # = false)
        # returns the smile for a given option date and swap tenor
        shared_ptr[SmileSection] smileSection(const Date& optionDate,
                                              const Period& swapTenor,
                                              bool extr) const # = false)
        # returns the smile for a given option time and swap tenor
        shared_ptr[SmileSection] smileSection(Time optionTime,
                                              const Period& swapTenor,
                                              bool extr) const # = false)
        # returns the smile for a given option tenor and swap length
        shared_ptr[SmileSection] smileSection(const Period& optionTenor,
                                              Time swapLength,
                                              bool extr) const # = false)
        # returns the smile for a given option date and swap length
        shared_ptr[SmileSection] smileSection(const Date& optionDate,
                                              Time swapLength,
                                              bool extr) const # = false)
        # returns the smile for a given option time and swap length
        shared_ptr[SmileSection] smileSection(Time optionTime,
                                              Time swapLength,
                                              bool extr) const # = false)

        VolatilityType volatilityType()
