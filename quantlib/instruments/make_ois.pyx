from quantlib.types cimport Natural, Rate, Real, Spread
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.utilities.null cimport Null
from quantlib.time.date cimport Date, Period
from quantlib.time._period cimport Days, Frequency
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.dategeneration cimport DateGeneration
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.pricingengines.engine cimport PricingEngine
cimport quantlib.indexes._ibor_index as _ii
from .. cimport _instrument as _in
from .overnightindexedswap cimport OvernightIndexedSwap
from .swap cimport Type
from ._overnightindexedswap cimport OvernightIndexedSwap as _OvernightIndexedSwap
from quantlib.indexes.ibor_index cimport OvernightIndex


cdef class MakeOIS:
    def __init__(self, Period swap_tenor not None,
                 OvernightIndex overnight_index not None,
                 Rate fixed_rate=Null[Real](),
                 Period forward_start not None=Period(0, Days)):
        self._thisptr = new _make_ois.MakeOIS(
            deref(swap_tenor._thisptr),
            static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
            fixed_rate,
            deref(forward_start._thisptr))

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __call__(self):
        cdef OvernightIndexedSwap instance = OvernightIndexedSwap.__new__(OvernightIndexedSwap)
        cdef shared_ptr[_OvernightIndexedSwap] temp = <shared_ptr[_OvernightIndexedSwap]>deref(self._thisptr)
        instance._thisptr = static_pointer_cast[_in.Instrument](temp)
        return instance

    def receive_fixed(self, bool flag=True):
        self._thisptr.receiveFixed(flag)
        return self

    def with_type(self, Type type):
        self._thiptr.withType(type)
        return self

    def with_nominal(self, Real n):
        self._thisptr.withNominal(n)
        return self

    def with_settlement_days(self, Natural days):
        self._thisptr.withSettlementDays(days)
        return self

    def with_effective_date(self, Date d):
        self._thisptr.withEffectiveDate(d._thisptr)
        return self

    def with_termination_date(self, Date d):
        self._thisptr.withTerminationDate(d._thisptr)
        return self

    def with_rule(self, DateGeneration r):
        self._thisptr.withRule(r)
        return self

    def with_payment_frequency(self, Frequency f):
        self._thisptr.withPaymentFrequency(f)
        return self

    def with_fixed_leg_payment_frequency(self, Frequency f):
        self._thisptr.withFixedLegPaymentFrequency(f)
        return self

    def with_overnight_leg_payment_frequency(self, Frequency f):
        self._thisptr.withOvernightLegPaymentFrequency(f)
        return self

    def with_payment_adjustment(self, BusinessDayConvention convention):
        self._thisptr.withPaymentAdjustment(convention)
        return self

    def with_payment_lag(self, Natural lag):
        self._thisptr.withPaymentLag(lag)
        return self

    def with_payment_calendar(self, Calendar cal not None):
        self._thisptr.withPaymentCalendar(cal._thisptr)
        return self

    def with_end_of_month(self, bool flag=True):
        self._thisptr.withEndOfMonth(flag)
        return self

    def with_fixed_leg_day_count(self, DayCounter dc not None):
        self._thisptr.withFixedLegDayCount(deref(dc._thisptr))
        return self

    def with_overnight_leg_spread(self, Spread sp):
        self._thisptr.withOvernightLegSpread(sp)
        return self

    def with_discounting_term_structure(self, HandleYieldTermStructure ts):
        self._thisptr.withDiscountingTermStructure(ts.handle)
        return self

    def with_telescopic_value_dates(self, bool telescopic_value_dates):
        self._thisptr.withTelescopicValueDates(telescopic_value_dates)
        return self

    def with_averaging_method(self, RateAveraging averagingMethod):
        self._thisptr.withAveragingMethod(averagingMethod)
        return self

    def with_lookback_days(self, Natural lookback_days):
        self._thisptr.withLookbackDays(lookback_days)
        return self

    def with_lockout_days(self, Natural lockout_days):
        self._thisptr.withLockoutDays(lockout_days)
        return self

    def with_apply_observation_shift(self, bool observation_shift):
        self._thisptr.withObservationShift(observation_shift)
        return self

    def with_pricing_engine(self, PricingEngine engine):
        self._thisptr.withPricingEngine(engine._thisptr)
        return self
