include '../../../types.pxi'
from libcpp cimport bool
from quantlib.handle cimport Handle
from quantlib._quote cimport Quote
from quantlib.time._date cimport Date, Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from ._swaption_vol_structure cimport \
        SwaptionVolatilityStructure
from quantlib.termstructures.volatility._volatilitytype cimport (
        VolatilityType, ShiftedLognormal)

cdef extern from 'ql/termstructures/volatility/swaption/swaptionconstantvol.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ConstantSwaptionVolatility(SwaptionVolatilityStructure):
        ConstantSwaptionVolatility(Natural settlementDays,
                                   const Calendar& cal,
                                   BusinessDayConvention bdc,
                                   const Handle[Quote]& volatility,
                                   const DayCounter& dc,
                                   const VolatilityType type, # = ShiftedLognormal,
                                   const Real shift)# = 0.0)
        # fixed reference date, floating market data
        ConstantSwaptionVolatility(const Date& referenceDate,
                                   const Calendar& cal,
                                   BusinessDayConvention bdc,
                                   const Handle[Quote]& volatility,
                                   const DayCounter& dc,
                                   const VolatilityType type, # = ShiftedLognormal,
                                   const Real shift) # = 0.0)
        # floating reference date, fixed market data
        ConstantSwaptionVolatility(Natural settlementDays,
                                   const Calendar& cal,
                                   BusinessDayConvention bdc,
                                   Volatility volatility,
                                   const DayCounter& dc,
                                   const VolatilityType type, # = ShiftedLognormal,
                                   const Real shift) # = 0.0)
        # fixed reference date, fixed market data
        ConstantSwaptionVolatility(const Date& referenceDate,
                                   const Calendar& cal,
                                   BusinessDayConvention bdc,
                                   Volatility volatility,
                                   const DayCounter& dc,
                                   const VolatilityType type, # = ShiftedLognormal,
                                   const Real shift) # = 0.0)
