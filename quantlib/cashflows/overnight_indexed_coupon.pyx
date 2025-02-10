from quantlib.types cimport Integer, Natural, Real, Spread

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.utility cimport move
from cython.operator cimport dereference as deref, preincrement as preinc
from quantlib.handle cimport make_shared, shared_ptr, static_pointer_cast
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as QlDate
from quantlib.time.calendar cimport Calendar
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.indexes.ibor_index cimport OvernightIndex
from quantlib.utilities.null cimport Null
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib._cashflow as _cf
from .rateaveraging cimport RateAveraging
from . cimport _overnight_indexed_coupon as _oic
from .._cashflow cimport Leg as QlLeg

cdef class OvernightIndexedCoupon(FloatingRateCoupon):

    def __init__(self, Date payment_date not None, Real nominal,
                 Date start_date not None, Date end_date not None,
                 OvernightIndex index not None, Real gearing=1., Spread spread=0.,
                 Date ref_period_start=Date(), Date ref_period_end=Date(),
                 DayCounter day_counter=DayCounter(), bool telescopic_values= False,
                 RateAveraging averaging_method=RateAveraging.Compound,
                 Natural lookback_days=Null[Natural](),
                 Natural lockout_days=0,
                 bool apply_observation_shift=False):
        self._thisptr = make_shared[_oic.OvernightIndexedCoupon](
                payment_date._thisptr, nominal,
                start_date._thisptr, end_date._thisptr,
                static_pointer_cast[_ii.OvernightIndex](index._thisptr),
                gearing, spread,
                ref_period_start._thisptr, ref_period_end._thisptr,
                deref(day_counter._thisptr), telescopic_values, averaging_method,
            lookback_days, lockout_days, apply_observation_shift
        )

    def fixing_dates(self):
        cdef:
            vector[QlDate].const_iterator it = (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).fixingDates().const_begin()
            Date date
            list l = []

        while it != (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).fixingDates().end():
            date = Date.__new__(Date)
            date._thisptr = deref(it)
            l.append(date)
            preinc(it)
        return l

    def dt(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).dt()

    def index_fixings(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).indexFixings()

    def value_dates(self):
        cdef:
            vector[QlDate].const_iterator it = (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).valueDates().const_begin()
            Date date
            list l = []

        while it != (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).valueDates().end():
            date = Date.__new__(Date)
            date._thisptr = deref(it)
            l.append(date)
            preinc(it)
        return l

    @property
    def lockout_days(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).lockoutDays()

    @property
    def averaging_method(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).averagingMethod()

    @property
    def apply_observation_shift(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).applyObservationShift()

cdef class OvernightLeg(Leg):

    def __iter__(self):
        cdef OvernightIndexedCoupon oic
        cdef vector[shared_ptr[_cf.CashFlow]].iterator it = self._thisptr.begin()
        while it != self._thisptr.end():
            oic = OvernightIndexedCoupon.__new__(OvernightIndexedCoupon)
            oic._thisptr = deref(it)
            yield oic
            preinc(it)

    def __init__(self, Schedule schedule, OvernightIndex index):
        self.leg = new _oic.OvernightLeg(schedule._thisptr,
                                         static_pointer_cast[_ii.OvernightIndex](index._thisptr))

    def __dealloc__(self):
        if self.leg is not NULL:
            del self.leg
            self.leg = NULL

    def with_notionals(self, Real notional):
        self.leg.withNotionals(notional)
        return self

    def with_payment_day_counter(self, DayCounter dc):
        self.leg.withPaymentDayCounter(deref(dc._thisptr))
        return self

    def with_payment_adjustment(self, BusinessDayConvention bdc):
        self.withPaymentAdjustment(bdc)
        return self

    def with_payment_calendar(self, Calendar cal):
        self.leg.withPaymentCalendar(cal._thisptr)
        return self

    def with_spreads(self, Spread spread):
        self.leg.withSpreads(spread)
        return self

    def with_observation_shift(self, bool apply_observation_shift=True):
        self.leg.withObservationShift(apply_observation_shift)
        return self

    def with_lookback_days(self, Natural lookback_days):
        self.leg.withLookbackDays(lookback_days)
        return self

    def with_lockout_days(self, Natural lockout_days):
        self.leg.withLockoutDays(lockout_days)
        return self

    def with_payment_lag(self, Integer lag):
        self.leg.withPaymentLag(lag)
        return self

    def __call__(self):
        self._thisptr = move[QlLeg](_oic.to_leg(deref(self.leg)))
        return self
