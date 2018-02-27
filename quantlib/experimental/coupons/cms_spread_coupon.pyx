include '../../types.pxi'
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, dynamic_pointer_cast
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from swap_spread_index cimport SwapSpreadIndex
cimport _cms_spread_coupon as _csc
cimport _swap_spread_index as _ssi
cimport quantlib._cashflow as _cf

cdef class CmsSpreadCoupon(FloatingRateCoupon):
    def __init__(self, Date payment_date not None,
            Real nominal,
            Date start_date not None,
            Date end_date not None,
            Natural fixing_days,
            SwapSpreadIndex index,
            Real gearing=1.,
            Real spread=0.,
            Date ref_period_start=Date(),
            Date ref_period_end=Date(),
            DayCounter day_counter=DayCounter(),
            bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
                new _csc.CmsSpreadCoupon(
                    deref(payment_date._thisptr),
                    nominal,
                    deref(start_date._thisptr),
                    deref(end_date._thisptr),
                    fixing_days,
                    dynamic_pointer_cast[_ssi.SwapSpreadIndex](index._thisptr),
                    gearing,
                    spread,
                    deref(ref_period_start._thisptr),
                    deref(ref_period_end._thisptr),
                    deref(day_counter._thisptr),
                    is_in_arrears))
