# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp cimport bool

cimport quantlib.instruments._instrument as _ins
from quantlib.instruments.swap cimport VanillaSwap
cimport quantlib.instruments._vanillaswap as _vs

from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
cimport quantlib.indexes._ibor_index as _ib
cimport quantlib.indexes._swap_index as _si
from quantlib.instruments.futures cimport FuturesType
from quantlib.time._period cimport Frequency, Days, Period as QlPeriod
from quantlib.time._businessdayconvention cimport (
    BusinessDayConvention, ModifiedFollowing )
from quantlib.time.date cimport date_from_qldate, period_from_qlperiod
from quantlib.quote cimport Quote
from quantlib.quotes.simplequote cimport SimpleQuote
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes.swap_index cimport SwapIndex

cdef class RateHelper:

    property quote:
        def __get__(self):
            cdef Quote r = Quote.__new__(Quote)
            r._thisptr = self._thisptr.get().quote().currentLink()
            return r

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
            elif isinstance(rate, Quote):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper((<Quote>rate).handle(),
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
            elif isinstance(rate, Quote):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper(
                        (<Quote>rate).handle(),
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
    def from_tenor(cls, rate, Period tenor not None,
        Calendar calendar not None, Frequency fixedFrequency,
        BusinessDayConvention fixedConvention, DayCounter fixedDayCount not None,
        IborIndex iborIndex not None, Quote spread=None,
        Period fwdStart=Period(0, Days)):

        cdef SwapRateHelper instance = SwapRateHelper.__new__(SwapRateHelper)

        if isinstance(rate, float):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                <Rate>rate,
                deref(tenor._thisptr),
                deref(calendar._thisptr),
                <Frequency> fixedFrequency,
                <_rh.BusinessDayConvention> fixedConvention,
                deref(fixedDayCount._thisptr),
                static_pointer_cast[_ib.IborIndex](iborIndex._thisptr),
                spread.handle() if spread else Quote.empty_handle(),
                deref(fwdStart._thisptr))
            )
        elif isinstance(rate, Quote):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                (<Quote>rate).handle(),
                deref(tenor._thisptr),
                deref(calendar._thisptr),
                <Frequency> fixedFrequency,
                <_rh.BusinessDayConvention> fixedConvention,
                deref(fixedDayCount._thisptr),
                static_pointer_cast[_ib.IborIndex](iborIndex._thisptr),
                spread.handle() if spread else Quote.empty_handle(),
                deref(fwdStart._thisptr))
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

        return instance

    @classmethod
    def from_index(cls, rate, SwapIndex index not None, Quote spread=SimpleQuote.__new__(SimpleQuote),
                   Period fwdStart=Period(0, Days)):
        cdef SwapRateHelper instance = cls.__new__(cls)

        if isinstance(rate, float):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                <Rate>rate,
                static_pointer_cast[_si.SwapIndex](index._thisptr),
                spread.handle(),
                deref(fwdStart._thisptr)
                )
            )
        elif isinstance(rate, Quote):
            instance._thisptr.reset(new _rh.SwapRateHelper(
                (<Quote>rate).handle(),
                static_pointer_cast[_si.SwapIndex](index._thisptr),
                spread.handle(),
                deref(fwdStart._thisptr)
            )
        )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

        return instance

    def swap(self):
        cdef VanillaSwap instance = VanillaSwap.__new__(VanillaSwap)
        instance._thisptr = static_pointer_cast[_ins.Instrument](
            (<_rh.SwapRateHelper*>self._thisptr.get()).swap())
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
        elif isinstance(rate, Quote):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    (<Quote>rate).handle(),
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
                 DayCounter day_counter, convexity_adjustment=0.0,
                 FuturesType future_type=FuturesType.IMM):

        if convexity_adjustment == 0.0 and isinstance(price, SimpleQuote):
            convexity_adjustment = SimpleQuote(0.0)
        if isinstance(price, float) and isinstance(convexity_adjustment, float):
            self._thisptr.reset(
                new _rh.FuturesRateHelper(
                    <Real>price,
                    deref(imm_date._thisptr),
                    length_in_months,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention> convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                    <Rate>convexity_adjustment,
                    future_type
                )
            )
        elif isinstance(price, Quote) and isinstance(convexity_adjustment, Quote):
            self._thisptr.reset(
                new _rh.FuturesRateHelper(
                    (<Quote>price).handle(),
                    deref(imm_date._thisptr),
                    length_in_months,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention> convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                    (<Quote>convexity_adjustment).handle(),
                    future_type
                )
            )
        else:
            raise ValueError('price needs to be a float or a SimpleQuote')

    @classmethod
    def from_index(cls, price, Date ibor_start_date, IborIndex i, convexity_adjustment=0.0, FuturesType future_type=FuturesType.IMM):
        cdef FuturesRateHelper instance = FuturesRateHelper.__new__(FuturesRateHelper)
        if convexity_adjustment == 0.0 and isinstance(price, SimpleQuote):
            convexity_adjustment = SimpleQuote(0.0)
        if isinstance(price, float) and isinstance(convexity_adjustment, float):
            instance._thisptr.reset(
                new _rh.FuturesRateHelper(<Real>price,
                                          deref(ibor_start_date._thisptr),
                                          static_pointer_cast[_ib.IborIndex](i._thisptr),
                                          <Rate>convexity_adjustment,
                                          future_type)
            )
        elif isinstance(price, Quote) and isinstance(convexity_adjustment, Quote):
            instance._thisptr.reset(
                new _rh.FuturesRateHelper((<Quote>price).handle(),
                                          deref(ibor_start_date._thisptr),
                                          static_pointer_cast[_ib.IborIndex](i._thisptr),
                                          (<Quote>convexity_adjustment).handle(),
                                          future_type)
            )
        else:
            raise ValueError('price needs to be a float or a SimpleQuote')
        return instance

    @property
    def convexity_adjustment(self):
        return (<_rh.FuturesRateHelper*>self._thisptr.get()).convexityAdjustment()
