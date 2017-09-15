
include '../../types.pxi'

from quantlib._quote cimport Quote
from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Period

from quantlib.indexes._inflation_index cimport (
    YoYInflationIndex, ZeroInflationIndex)
from quantlib.termstructures.inflation.inflation_traits cimport (
    ZeroInflationTraits, YoYInflationTraits)

cimport quantlib.termstructures._inflation_term_structure as _its

cdef extern from 'ql/termstructures/inflation/inflationhelpers.hpp' namespace 'QuantLib':
    cdef cppclass ZeroCouponInflationSwapHelper(ZeroInflationTraits.helper):
        ZeroCouponInflationSwapHelper(
            const Handle[Quote]& quote,
            const Period& swap_obs_lag,  # lag on swap observation of index
            const Date& maturity,
            const Calendar& calendar,  #index may have null calendar as valid on every day
            BusinessDayConvention payment_convention,
            const DayCounter& day_counter,
            const shared_ptr[ZeroInflationIndex]& zii) except +

    # Year-on-year inflation-swap bootstrap helper
    cdef cppclass YearOnYearInflationSwapHelper(YoYInflationTraits.helper):
        YearOnYearInflationSwapHelper(
            const Handle[Quote]& quote,
            const Period& swap_obs_lag,
            const Date& maturity,
            const Calendar& calendar,
            BusinessDayConvention payment_convention,
            const DayCounter& day_counter,
            const shared_ptr[YoYInflationIndex]& yii) except +
