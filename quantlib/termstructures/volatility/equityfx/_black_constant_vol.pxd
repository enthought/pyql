include '../../../types.pxi'
from quantlib.handle cimport Handle
from quantlib._quote cimport Quote
from quantlib.time._date cimport Date
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from _black_vol_term_structure cimport BlackVolatilityTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/blackconstantvol.hpp' namespace 'QuantLib':

    cdef cppclass BlackConstantVol(BlackVolatilityTermStructure):
        BlackConstantVol(Date& referenceDate,
                         Calendar& calendar,
                         Volatility volatility,
                         DayCounter& dayCounter)
        BlackConstantVol(const Date& referenceDate,
                         const Calendar&,
                         const Handle[Quote]& volatility,
                         const DayCounter& dayCounter)
        BlackConstantVol(Natural settlementDays,
                         const Calendar&,
                         Volatility volatility,
                         const DayCounter& dayCounter)
        BlackConstantVol(Natural settlementDays,
                         const Calendar&,
                         const Handle[Quote]& volatility,
                         const DayCounter& dayCounter)
