from quantlib.types cimport Natural, Real

from cython.operator cimport dereference as deref
from quantlib.default cimport Protection
from quantlib.handle cimport static_pointer_cast, shared_ptr
from quantlib.time.date cimport Date, Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._date cimport Date as QlDate, Period as QlPeriod
from quantlib.time.dategeneration cimport DateGeneration
from quantlib.pricingengines.engine cimport PricingEngine
from . cimport _credit_default_swap as _cds
from .. cimport _instrument as _in
from .credit_default_swap cimport CreditDefaultSwap
from ._make_cds cimport cast


cdef class MakeCreditDefaultSwap:
    def __init__(self, tenor_or_term_date not None, Real coupon_rate):
        if isinstance(tenor_or_term_date, Period):
            self._thisptr = new _make_cds.MakeCreditDefaultSwap(
                deref((<Period>tenor_or_term_date)._thisptr),
                coupon_rate)
        elif isinstance(tenor_or_term_date, Date):
            self._thisptr = new _make_cds.MakeCreditDefaultSwap(
                (<Date>tenor_or_term_date)._thisptr,
                coupon_rate)
        else:
            raise TypeError("tenor_or_term_date needs to be a Period or Date")


    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __call__(self):
        cdef CreditDefaultSwap instance = CreditDefaultSwap.__new__(CreditDefaultSwap)
        instance._thisptr = static_pointer_cast[_in.Instrument](
            cast(deref(self._thisptr))
        )
        return instance

    def with_upfront_rate(self, Real upf):
        self._thisptr.withUpfrontRate(upf)
        return self

    def with_side(self, Protection side):
        self._thisptr.withSide(side)
        return self

    def with_last_period_daycounter(self, DayCounter dc):
        self._thisptr.withLastPeriodDayCounter(deref(dc._thisptr))
        return self

    def with_date_generation_rule(self, DateGeneration rule):
        self._thisptr.withDateGenerationRule(rule)
        return self

    def with_cash_settlement_days(self, Natural days):
        self._thisptr.withCashSettlementDays(days)
        return self

    def with_nominal(self, Real n):
        self._thisptr.withNominal(n)
        return self

    def with_pricing_engine(self, PricingEngine pe):
        self._thisptr.withPricingEngine(pe._thisptr)
        return self
