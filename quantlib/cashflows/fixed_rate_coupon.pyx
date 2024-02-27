include '../types.pxi'

from cython.operator cimport dereference as deref, preincrement as preinc
from libcpp.vector cimport vector
from quantlib.compounding cimport Compounding
from quantlib.handle cimport shared_ptr
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.frequency cimport Frequency, Annual
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.schedule cimport Schedule
cimport quantlib._cashflow as _cf
from quantlib.interest_rate cimport InterestRate
cimport quantlib._interest_rate as _ir

cdef class FixedRateCoupon(Coupon):

    def __init__(self, Date payment_date not None, Real nominal, Rate rate,
                 DayCounter day_counter not None, Date accrual_start_date not None,
                 Date accrual_end_date not None, Date ref_period_start=Date(),
                 Date ref_period_end=Date(), Date ex_coupon_date=Date()):
        self._thisptr = shared_ptr[_cf.CashFlow](
            new _frc.FixedRateCoupon(deref(payment_date._thisptr), nominal,
                                     rate, deref(day_counter._thisptr),
                                     deref(accrual_start_date._thisptr),
                                     deref(accrual_end_date._thisptr),
                                     deref(ref_period_start._thisptr),
                                     deref(ref_period_end._thisptr),
                                     deref(ex_coupon_date._thisptr))
            )

    def interest_rate(self):
        cdef InterestRate ir = InterestRate.__new__(InterestRate)
        ir._thisptr = (<_frc.FixedRateCoupon*>self._thisptr.get()).interestRate()
        return ir

cdef class FixedRateLeg(Leg):

    def __init__(self, Schedule schedule):
        self.frl = new _frc.FixedRateLeg(schedule._thisptr)

    def with_notional(self, Real notional):
        self.frl.withNotionals(notional)
        return self

    def with_coupon_rates(self, Rate rate, DayCounter payment_day_counter, Compounding comp=Compounding.Simple, Frequency freq=Annual):
        self.frl.withCouponRates(rate, deref(payment_day_counter._thisptr), comp, freq)
        return self

    def with_payment_adjustment(self, BusinessDayConvention bdc):
        self.frl.withPaymentAdjustment(bdc)
        return self

    def with_payment_calendar(self, Calendar cal):
        self.frl.withPaymentCalendar(cal._thisptr)
        return self

    def with_last_period_day_counter(self, DayCounter dc):
        self.frl.withLastPeriodDayCounter(deref(dc._thisptr))
        return self

    def __call__(self):
        self._thisptr = _frc.to_leg(deref(self.frl))
        return self

    def __iter__(self):
        cdef FixedRateCoupon frc
        cdef vector[shared_ptr[_cf.CashFlow]].iterator it = self._thisptr.begin()
        while it != self._thisptr.end():
            frc = FixedRateCoupon.__new__(FixedRateCoupon)
            frc._thisptr = deref(it)
            yield frc
            preinc(it)

    def __repr__(self):
        """ Pretty print cash flow schedule. """

        header = "Cash Flow Schedule:\n"
        values = ("{0!s} {1:f}".format(frc.date, frc.amount) for frc in self)
        return header + '\n'.join(values)
