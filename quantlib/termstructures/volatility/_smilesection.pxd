include "../../types.pxi"
from quantlib.instruments.option cimport OptionType
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._date cimport Date
from ._volatilitytype cimport VolatilityType

cdef extern from 'ql/termstructures/volatility/smilesection.hpp' namespace 'QuantLib':
    cdef cppclass SmileSection:
        SmileSection(const Date& d,
                     const DayCounter& dc, # = DayCounter(),
                     const Date& referenceDate,# = Date(),
                     const VolatilityType type, # = ShiftedLognormal,
                     const Rate shift)# = 0.0);
        SmileSection(Time exerciseTime,
                     const DayCounter& dc, # = DayCounter(),
                     const VolatilityType type, # = ShiftedLognormal,
                     const Rate shift) # = 0.0);

        void update()
        Real minStrike()
        Real maxStrike()
        variance(Rate strike) const;
        Volatility volatility(Rate strike)
        Real atmLevel()
        const Date& exerciseDate()
        VolatilityType volatilityType()
        Rate shift()
        const Date& referenceDate()
        Time exerciseTime()
        const DayCounter& dayCounter()
        Real optionPrice(Rate strike,
                         OptionType option_type, # = Option::Call,
                         Real discount) #=1.0) const;
        Real digitalOptionPrice(Rate strike,
                                OptionType option_type, # = Option::Call,
                                Real discount, #=1.0,
                                Real gap) #=1.0e-5) const;
        Real vega(Rate strike,
                  Real discount) #=1.0) const;
        Real density(Rate strike,
                     Real discount, #=1.0,
                     Real gap) #=1.0E-4)
        Volatility volatility(Rate strike, VolatilityType vol_type, Real shift) #=0.0)
