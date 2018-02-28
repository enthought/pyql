include '../types.pxi'

from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
cimport _floating_rate_coupon as _frc
from coupon_pricer cimport FloatingRateCouponPricer
cimport quantlib._cashflow as _cf
from quantlib.indexes.interest_rate_index cimport InterestRateIndex
cimport quantlib.indexes._interest_rate_index as _iri

cdef class FloatingRateCoupon(Coupon):

    def __init__(self, Date payment_date not None, Real nominal,
                 Date start_date not None, Date end_date not None, Natural fixing_days,
                 InterestRateIndex index not None, Real gearing=1., Spread spread=0.,
                 Date ref_period_start=Date(), Date ref_period_end=Date(),
                 DayCounter day_counter=DayCounter(), bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
            new _frc.FloatingRateCoupon(
                deref(payment_date._thisptr), nominal,
                deref(start_date._thisptr), deref(end_date._thisptr),
                fixing_days,
                static_pointer_cast[_iri.InterestRateIndex](index._thisptr),
                gearing, spread,
                deref(ref_period_start._thisptr), deref(ref_period_end._thisptr),
                deref(day_counter._thisptr), is_in_arrears)
        )

    def set_pricer(self, FloatingRateCouponPricer pricer):
        (<_frc.FloatingRateCoupon*>self._thisptr.get()).setPricer(pricer._thisptr)
