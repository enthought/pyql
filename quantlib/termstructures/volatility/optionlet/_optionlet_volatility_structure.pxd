include '../../../types.pxi'

from quantlib.time._calendar cimport Calendar, BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency



cdef extern from 'ql/termstructures/voltermstructure.hpp' namespace 'QuantLib':

    cdef cppclass VolatilityTermStructure:
        VolatilityTermStructure() except +
        VolatilityTermStructure(
            Calendar& cal, 
            BusinessDayConvention bdc,
            DayCounter& dc
        ) except +

cdef extern from 'ql/termstructures/volatility/optionlet/optionletvolatilitystructure.hpp' namespace 'QuantLib':

    cdef cppclass OptionletVolatilityStructure(VolatilityTermStructure):
        OptionletVolatilityStructure() except +
        OptionletVolatilityStructure(
            Calendar& cal, 
            BusinessDayConvention bdc,
            DayCounter& dc
        ) except +

cdef extern from 'ql/termstructures/volatility/optionlet/constantoptionletvol.hpp' namespace 'QuantLib':

    cdef cppclass ConstantOptionletVolatility(OptionletVolatilityStructure):
        ConstantOptionletVolatility() except +
        ConstantOptionletVolatility(Date& referenceDate,
                         Calendar& cal,
                         BusinessDayConvention bdc,
                         Volatility volatility,
                         DayCounter& dayCounter) except +
        ConstantOptionletVolatility(Natural settlementDays, 
                         Calendar& cal, 
                         BusinessDayConvention bdc, 
                         Volatility volatility, 
                         DayCounter& dayCounter) except +

