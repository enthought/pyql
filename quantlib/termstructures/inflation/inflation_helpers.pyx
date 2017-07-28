from cython.operator cimport dereference as deref

cimport _inflation_helpers as _ih
from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.quotes cimport SimpleQuote
cimport quantlib._quote as _qt
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date
from quantlib.time.calendar cimport Calendar
from quantlib.indexes.inflation_index cimport (
    ZeroInflationIndex, YoYInflationIndex)
cimport quantlib.indexes._inflation_index as _ii

cdef class ZeroCouponInflationSwapHelper:
    def __cinit__(self, SimpleQuote quote, Period swap_obs_lag not None,
                  Date maturity not None, Calendar calendar not None,
                  BusinessDayConvention payment_convention,
                  DayCounter day_counter not None,
                  ZeroInflationIndex zii not None):
        self._thisptr = shared_ptr[_ih.ZeroCouponInflationSwapHelper](
            new _ih.ZeroCouponInflationSwapHelper(
                Handle[_qt.Quote](deref(quote._thisptr)),
                deref(swap_obs_lag._thisptr),
                deref(maturity._thisptr),
                deref(calendar._thisptr), payment_convention,
                deref(day_counter._thisptr),
                static_pointer_cast[_ii.ZeroInflationIndex](deref(zii._thisptr)))
            )

cdef class YearOnYearInflationSwapHelper:
    def __cinit__(self, SimpleQuote quote, Period swap_obs_lag not None,
                  Date maturity not None, Calendar calendar not None,
                  BusinessDayConvention payment_convention,
                  DayCounter day_counter not None,
                  YoYInflationIndex yii not None):
        self._thisptr = shared_ptr[_ih.YearOnYearInflationSwapHelper](
            new _ih.YearOnYearInflationSwapHelper(
                Handle[_qt.Quote](deref(quote._thisptr)),
                deref(swap_obs_lag._thisptr),
                deref(maturity._thisptr),
                deref(calendar._thisptr), payment_convention,
                deref(day_counter._thisptr),
                static_pointer_cast[_ii.YoYInflationIndex](deref(yii._thisptr)))
            )
