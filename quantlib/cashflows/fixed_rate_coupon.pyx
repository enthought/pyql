include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.cashflows._fixed_rate_coupon as _frc
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
        ir._thisptr = new shared_ptr[_ir.InterestRate](
            new _ir.InterestRate(
                (<_frc.FixedRateCoupon*>self._thisptr.get()).interestRate()))
        return ir
