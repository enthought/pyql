from quantlib.time._daycounter cimport DayCounter
from quantlib._quote cimport Quote
from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._period cimport Period
from quantlib.indexes._inflation_index cimport YoYInflationIndex

cdef extern from 'ql/termstructures/inflation/inflationhelpers.hpp' namespace 'QuantLib':
    cdef BootstrapHelper[ZeroInflationTermStructure] InflationHelper
    cdef cppclass ZeroCouponInflationSwapHelper(InflationHelper):
        ZeroCouponInflationHelper(
            const Handle[Quote]& quote,
            const Period& swap_obs_lag,  # lag on swap observation of index
            const Date& maturity,
            const Calendar& calendar,  #index may have null calendar as valid on every day
            BusinessDayConvention payment_convention,
            const DayCounter& day_counter,
            const shared_ptr[ZeroInflationIndex]& zii) except +
        void setTermStructure(ZeroInflationTermStructure*);
        Real impliedQuote() const

    # Year-on-year inflation-swap bootstrap helper
    cdef BootstrapHelper[YoYInflationTermStructure] YoYInflationHelper
    cdef cppclass YearOnYearInflationSwapHelper(YoYInflationHelper):
        YearOnYearInflationSwapHelper(
            const Handle[Quote]& quote,
            const Period& swap_obs_lag,
            const Date& maturity,
            const Calendar& calendar,
            BusinessDayConvention payment_convention,
            const DayCounter& day_counter,
            const shared_ptr[YoYInflationIndex]& yii)
        void setTermStructure(YoYInflationTermStructure*)
        Real impliedQuote() const
