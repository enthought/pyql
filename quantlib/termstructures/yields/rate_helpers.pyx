# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp cimport bool

cimport _rate_helpers as _rh
cimport quantlib.instruments._instrument as _ins
from quantlib.instruments.swap cimport VanillaSwap
cimport quantlib.instruments._vanillaswap as _vs

from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
cimport quantlib._quote as _qt
cimport quantlib.indexes._ibor_index as _ib
cimport quantlib.indexes._swap_index as _si
from quantlib.time._period cimport Frequency, Days, Period as QlPeriod
from quantlib.time._businessdayconvention cimport (
    BusinessDayConvention, ModifiedFollowing )
from quantlib.time.date cimport date_from_qldate, period_from_qlperiod
from quantlib.quotes cimport Quote, SimpleQuote
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes.swap_index cimport SwapIndex

cdef class RateHelper:

    property quote:
        def __get__(self):
            cdef shared_ptr[_qt.Quote] quote_ptr = self._thisptr.get().quote().currentLink()
            return quote_ptr.get().value()

        def __set__(self, Real val):
            cdef shared_ptr[_qt.Quote] quote = self._thisptr.get().quote().currentLink()
            cdef _qt.SimpleQuote* quote_ptr = <_qt.SimpleQuote*>(quote.get())
            quote_ptr.setValue(val)

    property implied_quote:
        def __get__(self):
            return self._thisptr.get().impliedQuote()

    @property
    def latest_date(self):
        return date_from_qldate(self._thisptr.get().latestDate())

cdef class RelativeDateRateHelper(RateHelper):

    def update(self):
        return self._thisptr.get().update()


cdef class DepositRateHelper(RelativeDateRateHelper):
    """Rate helper for bootstrapping over deposit rates."""

    def __init__(self, rate, Period tenor=None, Natural fixing_days=2,
        Calendar calendar=None, int convention=ModifiedFollowing,
        bool end_of_month=True, DayCounter deposit_day_counter=None,
        IborIndex index=None):

        if index is not None:
            if isinstance(rate, float):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper(<Rate>rate,
                                              static_pointer_cast[_ib.IborIndex](index._thisptr))
                )
            elif isinstance(rate, SimpleQuote):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper(Handle[_qt.Quote]((<SimpleQuote>rate)._thisptr),
                                              static_pointer_cast[_ib.IborIndex](index._thisptr)
                    )
                )
            else:
                raise ValueError('quote needs to be a float or a SimpleQuote')
        else:
            assert (tenor is not None and calendar is not None
                    and deposit_day_counter is not None), \
                    "Both tenor, calendar and deposit_day_counter have to be provided"
            if isinstance(rate, float):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper(
                        <Rate>rate,
                        deref(tenor._thisptr),
                        <int>fixing_days,
                        deref(calendar._thisptr),
                        <_rh.BusinessDayConvention>convention,
                        end_of_month,
                        deref(deposit_day_counter._thisptr)
                    )
                )
            elif isinstance(rate, SimpleQuote):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper(
                        Handle[_qt.Quote]((<SimpleQuote>rate)._thisptr),
                        deref(tenor._thisptr),
                        <int>fixing_days,
                        deref(calendar._thisptr),
                        <_rh.BusinessDayConvention>convention,
                        end_of_month,
                        deref(deposit_day_counter._thisptr)
                    )
                )
            else:
                raise ValueError('rate needs to be a float or a SimpleQuote')

cdef class SwapRateHelper(RelativeDateRateHelper):
    """Rate helper for bootstrapping over swap rates, use from_tenor or from_index function"""
    def __init__(self, from_classmethod=False):
        # Creating a SwaprRateHelper without using a class method means the
        # shared_ptr won't be initialized properly and break any subsequent calls
        # to the QuantLib internals... To avoid this, we raise a ValueError if
        # the user tries to instantiate this class if not setting the
        # from_classmethod. This is an ugly workaround but is ok so far.

        if from_classmethod is False:
            raise ValueError(
                'SwapRateHelpers must be instantiated through the class methods'
                ' from_index or from_tenor'
            )

    @classmethod
    def from_tenor(cls, rate, Period tenor,
        Calendar calendar, Frequency fixedFrequency,
        BusinessDayConvention fixedConvention, DayCounter fixedDayCount,
        IborIndex iborIndex, Quote spread=SimpleQuote(),
        Period fwdStart=Period(0, Days)):

        cdef Handle[_qt.Quote] spread_handle
        if spread._thisptr.get().isValid():
            spread_handle = Handle[_qt.Quote](spread._thisptr)
        else:
            spread_handle = Handle[_qt.Quote]()

        cdef SwapRateHelper instance = cls(from_classmethod=True)

        if isinstance(rate, float):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                <Rate>rate,
                deref(tenor._thisptr),
                deref(calendar._thisptr),
                <Frequency> fixedFrequency,
                <_rh.BusinessDayConvention> fixedConvention,
                deref(fixedDayCount._thisptr),
                static_pointer_cast[_ib.IborIndex](iborIndex._thisptr),
                spread_handle,
                deref(fwdStart._thisptr))
            )
        elif isinstance(rate, SimpleQuote):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                Handle[_qt.Quote]((<SimpleQuote>rate)._thisptr),
                deref(tenor._thisptr),
                deref(calendar._thisptr),
                <Frequency> fixedFrequency,
                <_rh.BusinessDayConvention> fixedConvention,
                deref(fixedDayCount._thisptr),
                static_pointer_cast[_ib.IborIndex](iborIndex._thisptr),
                spread_handle,
                deref(fwdStart._thisptr))
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

        return instance

    @classmethod
    def from_index(cls, rate, SwapIndex index not None, SimpleQuote spread=SimpleQuote(),
                   Period fwdStart=Period(0, Days)):
        cdef Handle[_qt.Quote] spread_handle
        if spread._thisptr.get().isValid():
            spread_handle = Handle[_qt.Quote](spread._thisptr)
        else:
            spread_handle = Handle[_qt.Quote]()
        cdef Handle[_qt.Quote] rate_handle
        cdef SwapRateHelper instance = cls.__new__(cls)

        if isinstance(rate, float):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                <Rate>rate,
                static_pointer_cast[_si.SwapIndex](index._thisptr),
                spread_handle,
                deref(fwdStart._thisptr)
                )
            )
        elif isinstance(rate, SimpleQuote):
            rate_handle = Handle[_qt.Quote]((<SimpleQuote>rate)._thisptr)
            instance._thisptr.reset(new _rh.SwapRateHelper(
                rate_handle,
                static_pointer_cast[_si.SwapIndex](index._thisptr),
                spread_handle,
                deref(fwdStart._thisptr)
            )
        )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

        return instance

    def swap(self):
        cdef VanillaSwap instance = VanillaSwap.__new__(VanillaSwap)
        instance._thisptr = new shared_ptr[_ins.Instrument](
            (<_rh.SwapRateHelper*>self._thisptr.get()).swap().get())
        return instance

    @property
    def spread(self):
        return (<_rh.SwapRateHelper*>self._thisptr.get()).spread()

    @property
    def forward_start(self):
        return period_from_qlperiod((<_rh.SwapRateHelper*>self._thisptr.get()).
                                    forwardStart())

cdef class FraRateHelper(RelativeDateRateHelper):
    """ Rate helper for bootstrapping over %FRA rates. """

    def __init__(self, rate, Natural months_to_start,
            Natural months_to_end, Natural fixing_days, Calendar calendar,
            BusinessDayConvention convention, bool end_of_month,
            DayCounter day_counter):

        if isinstance(rate, float):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    <Rate>rate,
                    months_to_start,
                    months_to_end,
                    fixing_days,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention> convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                )
                 )
        elif isinstance(rate, SimpleQuote):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    Handle[_qt.Quote]((<SimpleQuote>rate)._thisptr),
                    months_to_start,
                    months_to_end,
                    fixing_days,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention> convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                )
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')


cdef class FuturesRateHelper(RateHelper):
    """ Rate helper for bootstrapping over IborIndex futures prices. """

    def __init__(self, price, Date imm_date,
            Natural length_in_months, Calendar calendar,
            BusinessDayConvention convention, bool end_of_month,
            DayCounter day_counter, double convexity_adjustment = 0):

        if isinstance(price, float):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FuturesRateHelper(
                    <Real>price,
                    deref(imm_date._thisptr),
                    length_in_months,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention> convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                    <Rate>convexity_adjustment
                )
             )
        elif isinstance(price, SimpleQuote):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FuturesRateHelper(
                    Handle[_qt.Quote]((<SimpleQuote>price)._thisptr),
                    deref(imm_date._thisptr),
                    length_in_months,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention> convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                    Handle[_qt.Quote](shared_ptr[_qt.Quote](
                        new _qt.SimpleQuote(convexity_adjustment)))
                )
             )
        else:
            raise ValueError('price needs to be a float or a SimpleQuote')
