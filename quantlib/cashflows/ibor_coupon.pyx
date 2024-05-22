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
                 Natural fixing_days, IborIndex index not None, Real gearing=1.,
                 Spread spread=0.,
                 Date ref_period_start=Date(), Date ref_period_end=Date(),
                 DayCounter day_counter=DayCounter(), bool is_in_arrears=False):
        self._thisptr = shared_ptr[_cf.CashFlow](
            new _ic.IborCoupon(
                payment_date._thisptr, nominal,
                start_date._thisptr, end_date._thisptr,
                fixing_days,
                static_pointer_cast[_ii.IborIndex](index._thisptr),
                gearing, spread,
                ref_period_start._thisptr, ref_period_end._thisptr,
                deref(day_counter._thisptr), is_in_arrears)
        )
    Settings = IborCouponSettings()

cdef class IborCouponSettings:
    @staticmethod
    def create_at_par_coupons():
        _ic.Settings.instance().createAtParCoupons()

    @staticmethod
    def create_indexed_coupons():
        _ic.Settings.instance().createIndexedCoupons()

    @staticmethod
    def using_at_par_coupons():
        return _ic.Settings.instance().usingAtParCoupons()

cdef class IborLeg(Leg):
    def __iter__(self):
        cdef shared_ptr[_cf.CashFlow] cf
        cdef IborCoupon ic = IborCoupon.__new__(IborCoupon)
        for cf in self._thisptr:
            ic._thisptr = cf
            yield ic

    def __repr__(self):
        """ Pretty print cash flow schedule. """

        header = "Cash Flow Schedule:\n"
        values = ("{0!s} {1:f}".format(ic.date, ic.amount) for ic in self)
        return header + '\n'.join(values)
