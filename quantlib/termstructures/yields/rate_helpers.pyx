# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
""" deposit, FRA, futures and various swap rate helpers"""
from quantlib.types cimport Integer, Natural, Real, Rate
from cython.operator cimport dereference as deref
from libcpp cimport bool

cimport quantlib._instrument as _ins
from quantlib.instruments.vanillaswap cimport VanillaSwap
cimport quantlib.instruments._vanillaswap as _vs

from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
cimport quantlib.indexes._ibor_index as _ib
cimport quantlib.indexes._swap_index as _si
from quantlib.instruments.futures cimport FuturesType
from quantlib.time._period cimport Frequency, Days, Period as QlPeriod
from quantlib.time.businessdayconvention cimport (
    BusinessDayConvention, ModifiedFollowing )
from quantlib.time.date cimport date_from_qldate, period_from_qlperiod
from quantlib.quote cimport Quote
from quantlib.quotes.simplequote cimport SimpleQuote
from quantlib.time.calendar cimport Calendar
cimport quantlib.time._calendar as _cal
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes.swap_index cimport SwapIndex
from ..helpers cimport Pillar
from quantlib.utilities.null cimport Null
from ..yield_term_structure cimport HandleYieldTermStructure

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

    @property
    def earliest_date(self):
        return date_from_qldate(self._thisptr.get().earliestDate())

    @property
    def maturity_date(self):
        return date_from_qldate(self._thisptr.get().maturityDate())

    def update(self):
        return self._thisptr.get().update()

cdef class RelativeDateRateHelper(RateHelper):
    pass


cdef class DepositRateHelper(RelativeDateRateHelper):
    """Rate helper for bootstrapping over deposit rates."""

    def __init__(self, rate, Period tenor=None, Natural fixing_days=2,
        Calendar calendar=None, BusinessDayConvention convention=ModifiedFollowing,
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
                        fixing_days,
                        calendar._thisptr,
                        convention,
                        end_of_month,
                        deref(deposit_day_counter._thisptr)
                    )
                )
            elif isinstance(rate, Quote):
                self._thisptr = shared_ptr[_rh.RateHelper](
                    new _rh.DepositRateHelper(
                        (<Quote>rate).handle(),
                        deref(tenor._thisptr),
                        fixing_days,
                        calendar._thisptr,
                        convention,
                        end_of_month,
                        deref(deposit_day_counter._thisptr)
                    )
                )
            else:
                raise ValueError('rate needs to be a float or a SimpleQuote')

cdef class SwapRateHelper(RelativeDateRateHelper):
    """Rate helper for bootstrapping over swap rates"""
    def __init__(self):
        # Creating a SwapRateHelper without using a class method means the
        # shared_ptr won't be initialized properly and break any subsequent calls
        # to the QuantLib internals... To avoid this, we raise a ValueError if
        # the user tries to instantiate this class if not setting the
        # from_classmethod. This is an ugly workaround but is ok so far.

        raise ValueError(
            'SwapRateHelpers must be instantiated through the class methods'
            ' from_index or from_tenor'
        )

    @classmethod
    def from_tenor(cls, rate, Period tenor not None,
                   Calendar calendar not None, Frequency fixedFrequency,
                   BusinessDayConvention fixedConvention, DayCounter fixedDayCount not None,
                   IborIndex iborIndex not None, Quote spread=SimpleQuote.__new__(SimpleQuote),
                   Period fwdStart=Period(0, Days),
                   HandleYieldTermStructure discounting_curve=HandleYieldTermStructure(),
                   Natural settlement_days=Null[Integer](),
                   Pillar pillar=Pillar.LastRelevantDate,
                   Date custom_pillar_date=Date(),
                   bool end_of_month=False):

        cdef SwapRateHelper instance = SwapRateHelper.__new__(SwapRateHelper)

        if isinstance(rate, float):
            instance._thisptr.reset(
                new _rh.SwapRateHelper(
                    <Rate>rate,
                    deref(tenor._thisptr),
                    calendar._thisptr,
                    <Frequency> fixedFrequency,
                    fixedConvention,
                    deref(fixedDayCount._thisptr),
                    static_pointer_cast[_ib.IborIndex](iborIndex._thisptr),
                    spread.handle(),
                    deref(fwdStart._thisptr),
                    discounting_curve.handle,
                    settlement_days,
                    pillar,
                    custom_pillar_date._thisptr,
                    end_of_month
                )
            )
        elif isinstance(rate, Quote):
            instance._thisptr.reset(
                new _rh.SwapRateHelper(
                    (<Quote>rate).handle(),
                    deref(tenor._thisptr),
                    calendar._thisptr,
                    <Frequency> fixedFrequency,
                    fixedConvention,
                    deref(fixedDayCount._thisptr),
                    static_pointer_cast[_ib.IborIndex](iborIndex._thisptr),
                    spread.handle(),
                    deref(fwdStart._thisptr),
                    discounting_curve.handle,
                    settlement_days,
                    pillar,
                    custom_pillar_date._thisptr,
                    end_of_month
                )
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

        return instance

    @classmethod
    def from_index(cls, rate, SwapIndex index not None, Quote spread=SimpleQuote.__new__(SimpleQuote),
                   Period fwdStart=Period(0, Days),
                   HandleYieldTermStructure discounting_curve=HandleYieldTermStructure(),
                   Pillar pillar=Pillar.LastRelevantDate,
                   Date custom_pillar_date=Date(),
                   bool end_of_month=False):
        "build a SwapRateHelper from a SwapIndex"
        cdef SwapRateHelper instance = cls.__new__(cls)

        if isinstance(rate, float):
            instance._thisptr.reset(
                new _rh.SwapRateHelper(
                    <Rate>rate,
                    static_pointer_cast[_si.SwapIndex](index._thisptr),
                    spread.handle(),
                    deref(fwdStart._thisptr),
                    discounting_curve.handle,
                    pillar,
                    custom_pillar_date._thisptr,
                    end_of_month
                )
            )
        elif isinstance(rate, Quote):
            instance._thisptr.reset(
                new _rh.SwapRateHelper(
                    (<Quote>rate).handle(),
                    static_pointer_cast[_si.SwapIndex](index._thisptr),
                    spread.handle(),
                    deref(fwdStart._thisptr),
                    discounting_curve.handle,
                    pillar,
                    custom_pillar_date._thisptr,
                    end_of_month
                )
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

        return instance

    def swap(self):
        cdef VanillaSwap instance = VanillaSwap.__new__(VanillaSwap)
        instance._thisptr = (<_rh.SwapRateHelper*>self._thisptr.get()).swap()
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
                 DayCounter day_counter, Pillar pillar=Pillar.LastRelevantDate,
                   Date custom_pillar_date=Date(),
                   bool use_indexed_coupon=True):

        if isinstance(rate, float):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    <Rate>rate,
                    months_to_start,
                    months_to_end,
                    fixing_days,
                    calendar._thisptr,
                    convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                    pillar,
                    custom_pillar_date._thisptr,
                    use_indexed_coupon
                )
                 )
        elif isinstance(rate, Quote):
            self._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    (<Quote>rate).handle(),
                    months_to_start,
                    months_to_end,
                    fixing_days,
                    calendar._thisptr,
                    convention,
                    end_of_month,
                    deref(day_counter._thisptr),
                    pillar,
                    custom_pillar_date._thisptr,
                    use_indexed_coupon
                )
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')

    @classmethod
    def from_index(cls, rate, Natural months_to_start, IborIndex index not None,
                   Pillar pillar=Pillar.LastRelevantDate,
                   Date custom_pillar_date=Date(),
                   bool use_indexed_coupon=True):

        cdef FraRateHelper instance = FraRateHelper.__new__(FraRateHelper)
        if isinstance(rate, float):
            instance._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    <Rate>rate,
                    months_to_start,
                    static_pointer_cast[_ib.IborIndex](index._thisptr),
                    pillar,
                    custom_pillar_date._thisptr,
                    use_indexed_coupon
                )
            )
        elif isinstance(rate, Quote):
            instance._thisptr = shared_ptr[_rh.RateHelper](
                new _rh.FraRateHelper(
                    (<Quote>rate).handle(),
                    months_to_start,
                    static_pointer_cast[_ib.IborIndex](index._thisptr),
                    pillar,
                    custom_pillar_date._thisptr,
                    use_indexed_coupon
                )
            )
        else:
            raise ValueError('rate needs to be a float or a SimpleQuote')
        return instance

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
                    imm_date._thisptr,
                    length_in_months,
                    calendar._thisptr,
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
                    imm_date._thisptr,
                    length_in_months,
                    calendar._thisptr,
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
                                          ibor_start_date._thisptr,
                                          static_pointer_cast[_ib.IborIndex](i._thisptr),
                                          <Rate>convexity_adjustment,
                                          future_type)
            )
        elif isinstance(price, Quote) and isinstance(convexity_adjustment, Quote):
            instance._thisptr.reset(
                new _rh.FuturesRateHelper((<Quote>price).handle(),
                                          ibor_start_date._thisptr,
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

cdef class FxSwapRateHelper(RelativeDateRateHelper):
    """ Rate helper for bootstrapping over Fx Swap rates

    The forward is given by `fwdFx = spotFx + fwdPoint`.
    `isFxBaseCurrencyCollateralCurrency` indicates if the base
    currency of the FX currency pair is the one used as collateral.
    `calendar` is usually the joint calendar of the two currencies
    in the pair.
    `tradingCalendar` can be used when the cross pairs don't
    include the currency of the business center (usually USD; the
    corresponding calendar is `UnitedStates`).  If given, it will
    be used for adjusting the earliest settlement date and for
    setting the latest date. Due to FX spot market conventions, it
    is not sufficient to pass a JointCalendar with UnitedStates
    included as `calendar`; with regard the earliest date, this
    calendar is only used in case the spot date of the two
    currencies is not a US business day.

    .. warning::

       The ON fx swaps can be achieved by setting
       `fixingDays` to 0 and using a tenor of '1d'. The same
       tenor should be used for TN swaps, with `fixingDays`
       set to 1.  However, handling ON and TN swaps for
       cross rates without USD is not trivial and should be
       treated with caution. If today is a US holiday, ON
       trade is not possible. If tomorrow is a US Holiday,
       the ON trade will be at least two business days long
       in the other countries and the TN trade will not
       exist. In such cases, if this helper is used for
       curve construction, probably it is safer not to pass
       a trading calendar to the ON and TN helpers and
       provide fwdPoints that will yield proper level of
       discount factors.
    """

    def __init__(self, Quote fwd_point, Quote spot_fx,
                 Period tenor,
                 Natural fixing_days,
                 Calendar calendar,
                 BusinessDayConvention convention,
                 bool end_of_month,
                 bool is_fx_base_currency_collateral_currency,
                 HandleYieldTermStructure collateral_curve,
                 Calendar trading_calendar=Calendar()):

        self._thisptr.reset(
            new _rh.FxSwapRateHelper(
                fwd_point.handle(),
                spot_fx.handle(),
                deref(tenor._thisptr),
                fixing_days,
                calendar._thisptr,
                <_rh.BusinessDayConvention>convention,
                end_of_month,
                is_fx_base_currency_collateral_currency,
                collateral_curve.handle,
                trading_calendar._thisptr,
            )
        )

    cdef inline _rh.FxSwapRateHelper* as_ptr(self):
        return <_rh.FxSwapRateHelper*>self._thisptr.get()

    @property
    def spot(self):
        return self.as_ptr().spot()

    @property
    def tenor(self):
        cdef Period r = Period.__new__(Period)
        r._thisptr.reset(new QlPeriod(self.as_ptr().tenor()))
        return r

    @property
    def calendar(self):
        cdef Calendar r = Calendar.__new__(Calendar)
        r._thisptr = self.as_ptr().calendar()
        return r

    @property
    def business_day_convention(self):
        return self.as_ptr().businessDayConvention()

    @property
    def end_of_month(self):
        return self.as_ptr().endOfMonth()

    @property
    def is_fx_base_currency_collateral_currency(self):
        return self.as_ptr().isFxBaseCurrencyCollateralCurrency()

    @property
    def trading_calendar(self):
        cdef Calendar r = Calendar.__new__(Calendar)
        r._thisptr = self.as_ptr().tradingCalendar()
        return r

    @property
    def adjustment_calendar(self):
        cdef Calendar r = Calendar.__new__(Calendar)
        r._thisptr = self.as_ptr().adjustmentCalendar()
        return r
