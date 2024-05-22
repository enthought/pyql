include '../../types.pxi'
from libcpp cimport bool
from cython.operator cimport dereference as deref

from quantlib.utilities.null cimport Null
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from .swap_spread_index cimport SwapSpreadIndex
from . cimport _cms_spread_coupon as _csc
from . cimport _swap_spread_index as _ssi
cimport quantlib._index as _ii
cimport quantlib._cashflow as _cf

cdef class CmsSpreadCoupon(FloatingRateCoupon):
    def __init__(self, Date payment_date not None,
            Real nominal,
            Date start_date not None,
            Date end_date not None,
            Natural fixing_days,
            SwapSpreadIndex index not None,
            Real gearing=1.,
            Real spread=0.,
            Date ref_period_start=Date(),
            Date ref_period_end=Date(),
            DayCounter day_counter=DayCounter(),
            bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
                new _csc.CmsSpreadCoupon(
                    payment_date._thisptr,
                    nominal,
                    start_date._thisptr,
                    end_date._thisptr,
                    fixing_days,
                    static_pointer_cast[_ssi.SwapSpreadIndex](index._thisptr),
                    gearing,
                    spread,
                    ref_period_start._thisptr,
                    ref_period_end._thisptr,
                    deref(day_counter._thisptr),
                    is_in_arrears))

    @property
    def swap_spread_index(self):
        cdef SwapSpreadIndex instance = SwapSpreadIndex.__new__(SwapSpreadIndex)
        instance._thisptr = static_pointer_cast[_ii.Index](
            (<_csc.CmsSpreadCoupon*>self._thisptr.get()).swapSpreadIndex())
        return instance


cdef class CappedFlooredCmsSpreadCoupon(CappedFlooredCoupon):
    def __init__(self, Date payment_date not None,
                 Real nominal,
                 Date start_date not None,
                 Date end_date not None,
                 Natural fixing_days,
                 SwapSpreadIndex index not None,
                 Real gearing=1.,
                 Spread spread=0.,
                 Rate cap=Null[Real](),
                 Rate floor=Null[Real](),
                 Date ref_period_start=Date(),
                 Date ref_period_end=Date(),
                 DayCounter day_counter=DayCounter(),
                 bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
            new _csc.CappedFlooredCmsSpreadCoupon(
                payment_date._thisptr,
                nominal,
                start_date._thisptr,
                end_date._thisptr,
                fixing_days,
                static_pointer_cast[_ssi.SwapSpreadIndex](index._thisptr),
                gearing,
                spread,
                cap,
                floor,
                ref_period_start._thisptr,
                ref_period_end._thisptr,
                deref(day_counter._thisptr),
                is_in_arrears))
