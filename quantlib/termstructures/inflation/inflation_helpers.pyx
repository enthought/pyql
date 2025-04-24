from cython.operator cimport dereference as deref

from . cimport _inflation_helpers as _ih
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.quote cimport Quote
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date, date_from_qldate
from quantlib.time.calendar cimport Calendar
from quantlib.indexes.inflation_index cimport (
    ZeroInflationIndex, YoYInflationIndex)
cimport quantlib.indexes._inflation_index as _ii
from quantlib.indexes._inflation_index cimport CPI
from quantlib.indexes.inflation_index cimport InterpolationType
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.termstructures.inflation_term_structure cimport (
    ZeroInflationTermStructure, YoYInflationTermStructure)
cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib.termstructures.inflation._inflation_helpers as _ih

cdef class ZeroCouponInflationSwapHelper:
    def __init__(self, Quote quote, Period swap_obs_lag not None,
                 Date maturity not None, Calendar calendar not None,
                 BusinessDayConvention payment_convention,
                 DayCounter day_counter not None,
                 ZeroInflationIndex zii not None,
                 InterpolationType observation_interpolation,
                 HandleYieldTermStructure nominal_term_structure not None):
        self._thisptr = shared_ptr[ZeroInflationTraits.helper](
            new _ih.ZeroCouponInflationSwapHelper(
                quote.handle(),
                deref(swap_obs_lag._thisptr),
                maturity._thisptr,
                calendar._thisptr, payment_convention,
                deref(day_counter._thisptr),
                static_pointer_cast[_ii.ZeroInflationIndex](zii._thisptr),
                <CPI.InterpolationType>observation_interpolation,
                nominal_term_structure.handle)
            )

    def set_term_structure(self, ZeroInflationTermStructure ts):
        (<_ih.ZeroCouponInflationSwapHelper*>self._thisptr.get()).setTermStructure(
            <_its.ZeroInflationTermStructure*>ts._thisptr.get())

    @property
    def implied_quote(self):
        return self._thisptr.get().impliedQuote()

    @property
    def latest_date(self):
        return date_from_qldate(self._thisptr.get().latestDate())

cdef class YearOnYearInflationSwapHelper:
    def __init__(self, Quote quote, Period swap_obs_lag not None,
                  Date maturity not None, Calendar calendar not None,
                  BusinessDayConvention payment_convention,
                  DayCounter day_counter not None,
                  YoYInflationIndex yii not None,
                  InterpolationType interpolation,
                  HandleYieldTermStructure nominal_term_structure not None):
        self._thisptr = shared_ptr[YoYInflationTraits.helper](
            new _ih.YearOnYearInflationSwapHelper(
                quote.handle(),
                deref(swap_obs_lag._thisptr),
                maturity._thisptr,
                calendar._thisptr, payment_convention,
                deref(day_counter._thisptr),
                static_pointer_cast[_ii.YoYInflationIndex](yii._thisptr),
                <CPI.InterpolationType>interpolation,
                nominal_term_structure.handle)
            )

    def set_term_structure(self, YoYInflationTermStructure ts):
        (<_ih.YearOnYearInflationSwapHelper*>self._thisptr.get()).setTermStructure(
            <_its.YoYInflationTermStructure*>ts._thisptr.get())
    @property
    def implied_quote(self):
        return self._thisptr.get().impliedQuote()

    @property
    def latest_date(self):
        return date_from_qldate(self._thisptr.get().latestDate())
