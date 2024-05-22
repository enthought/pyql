include '../types.pxi'
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.indexes.swap_index cimport SwapIndex
from . cimport _cms_coupon as _cc
cimport quantlib.indexes._swap_index as _si
cimport quantlib._index as _ii
cimport quantlib._cashflow as _cf

cdef class CmsCoupon(FloatingRateCoupon):
    def __init__(self, Date payment_date not None,
            Real nominal,
            Date start_date not None,
            Date end_date not None,
            Natural fixing_days,
            SwapIndex index,
            Real gearing=1.,
            Real spread=0.,
            Date ref_period_start=Date(),
            Date ref_period_end=Date(),
            DayCounter day_counter=DayCounter(),
            bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
                new _cc.CmsCoupon(
                    payment_date._thisptr,
                    nominal,
                    start_date._thisptr,
                    end_date._thisptr,
                    fixing_days,
                    static_pointer_cast[_si.SwapIndex](index._thisptr),
                    gearing,
                    spread,
                    ref_period_start._thisptr,
                    ref_period_end._thisptr,
                    deref(day_counter._thisptr),
                    is_in_arrears))

    @property
    def swap_index(self):
        cdef SwapIndex instance = SwapIndex.__new__(SwapIndex)
        instance._thisptr = static_pointer_cast[_ii.Index](
            (<_cc.CmsCoupon*>self._thisptr.get()).swapIndex())
        return instance
