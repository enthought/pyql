include '../types.pxi'

from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.daycounter cimport DayCounter
cimport _floating_rate_coupon as _frc
from coupon_pricer cimport FloatingRateCouponPricer
cimport quantlib._cashflow as _cf
from quantlib.indexes.interest_rate_index cimport InterestRateIndex
cimport quantlib.indexes._interest_rate_index as _iri
from quantlib._index cimport Index

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

    def set_pricer(self, FloatingRateCouponPricer pricer not None):
        if type(self) is FloatingRateCoupon:
            raise NotImplementedError("virtual method")
        else:
            (<_frc.FloatingRateCoupon*>self._thisptr.get()).setPricer(pricer._thisptr)

    @property
    def fixing_days(self):
        return (<_frc.FloatingRateCoupon*>self._thisptr.get()).fixingDays()

    @property
    def fixing_date(self):
        if type(self) is FloatingRateCoupon:
            raise NotImplementedError("virtual method")
        else:
            return date_from_qldate((<_frc.FloatingRateCoupon*>self._thisptr.get()).fixingDate())

    @property
    def index(self):
        cdef InterestRateIndex r = InterestRateIndex.__new__(InterestRateIndex)
        r._thisptr = static_pointer_cast[Index]((<_frc.FloatingRateCoupon*>self._thisptr.get()).index())
        return r

    @property
    def index_fixing(self):
        if type(self) is FloatingRateCoupon:
            raise NotImplementedError("virtual method")
        else:
            return (<_frc.FloatingRateCoupon*>self._thisptr.get()).indexFixing()

    @property
    def convexity_adjustment(self):
        if type(self) is FloatingRateCoupon:
            raise NotImplementedError("virtual method")
        else:
            return (<_frc.FloatingRateCoupon*>self._thisptr.get()).convexityAdjustment()

    @property
    def adjusted_fixing(self):
        if type(self) is FloatingRateCoupon:
            raise NotImplementedError("virtual method")
        else:
            return (<_frc.FloatingRateCoupon*>self._thisptr.get()).adjustedFixing()
