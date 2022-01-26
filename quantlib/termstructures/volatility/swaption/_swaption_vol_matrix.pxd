include '../../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.time._date cimport Date, Period
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.handle cimport shared_ptr, Handle
from quantlib._quote cimport Quote
from ._swaption_vol_structure cimport SwaptionVolatilityStructure
from .._volatilitytype cimport VolatilityType
from quantlib.math._matrix cimport Matrix

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvolmatrix.hpp' namespace 'QuantLib':
    # this should really be constructors,
    # but cython can't disambiguate the constructors otherwise
    # floating reference date, floating market data
    SwaptionVolatilityMatrix* SwaptionVolatilityMatrix_ "new QuantLib::SwaptionVolatilityMatrix" (
                    const Calendar& calendar,
                    BusinessDayConvention bdc,
                    const vector[Period]& optionTenors,
                    const vector[Period]& swapTenors,
                    const vector[vector[Handle[Quote]]]& vols,
                    const DayCounter& dayCounter,
                    const bool flatExtrapolation, # = false,
                    VolatilityType type, # = ShiftedLognormal,
                    vector[vector[Real]]& shifts) except +#= vector[vector[Real]]());
    # fixed reference date, floating market data
    SwaptionVolatilityMatrix* SwaptionVolatilityMatrix__"new QuantLib::SwaptionVolatilityMatrix" (
                    const Date& referenceDate,
                    const Calendar& calendar,
                    BusinessDayConvention bdc,
                    const vector[Period]& optionTenors,
                    const vector[Period]& swapTenors,
                    const vector[vector[Handle[Quote]]]& vols,
                    const DayCounter& dayCounter,
                    const bool flatExtrapolation, # = false,
                    VolatilityType type, # = ShiftedLognormal,
                    vector[vector[Real]]& shifts) except +# = vector[vector[Real]]());
    cdef cppclass SwaptionVolatilityMatrix(SwaptionVolatilityStructure):
        # floating reference date, fixed market data
        SwaptionVolatilityMatrix(
                    const Calendar& calendar,
                    BusinessDayConvention bdc,
                    const vector[Period]& optionTenors,
                    const vector[Period]& swapTenors,
                    const Matrix& volatilities,
                    const DayCounter& dayCounter,
                    const bool flatExtrapolation, # = false,
                    const VolatilityType type, # = ShiftedLognormal,
                    const Matrix& shifts) except +#= Matrix())
        # fixed reference date, fixed market data
        SwaptionVolatilityMatrix(
                    const Date& referenceDate,
                    const Calendar& calendar,
                    BusinessDayConvention bdc,
                    const vector[Period]& optionTenors,
                    const vector[Period]& swapTenors,
                    const Matrix& volatilities,
                    const DayCounter& dayCounter,
                    const bool flatExtrapolation, #= false,
                    VolatilityType type, # = ShiftedLognormal,
                    const Matrix& shifts) except +#= Matrix());
        # fixed reference date and fixed market data, option dates
        SwaptionVolatilityMatrix(const Date& referenceDate,
                                 const vector[Date]& optionDates,
                                 const vector[Period]& swapTenors,
                                 const Matrix& volatilities,
                                 const DayCounter& dayCounter,
                                 const bool flatExtrapolation, # = false,
                                 const VolatilityType type, # = ShiftedLognormal,
                                 const Matrix& shifts) except + # = Matrix());
