include '../types.pxi'

from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.cashflows._ibor_coupon as _ic
cimport quantlib._cashflow as _cf
cimport quantlib.indexes._ibor_index as _ii
from quantlib.indexes.ibor_index cimport IborIndex

cdef class IborCoupon(FloatingRateCoupon):

    def __init__(self, Date payment_date not None, Real nominal,
                 Date start_date not None, Date end_date not None,
                 Natural fixing_days, IborIndex index, Real gearing=1.,
                 Spread spread=0.,
                 Date ref_period_start=Date(), Date ref_period_end=Date(),
                 DayCounter day_counter=DayCounter(), bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
            new _ic.IborCoupon(
                deref(payment_date._thisptr), nominal,
                deref(start_date._thisptr), deref(end_date._thisptr),
                fixing_days,
                static_pointer_cast[_ii.IborIndex](deref(index._thisptr)),
                gearing, spread,
                deref(ref_period_start._thisptr), deref(ref_period_end._thisptr),
                deref(day_counter._thisptr), is_in_arrears)
        )
