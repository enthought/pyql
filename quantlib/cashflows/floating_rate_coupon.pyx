from quantlib.types cimport Natural, Real, Spread
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.daycounter cimport DayCounter
from .coupon_pricer cimport FloatingRateCouponPricer
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
                payment_date._thisptr, nominal,
                start_date._thisptr, end_date._thisptr,
                fixing_days,
                static_pointer_cast[_iri.InterestRateIndex](index._thisptr),
                gearing, spread,
                ref_period_start._thisptr, ref_period_end._thisptr,
                deref(day_counter._thisptr), is_in_arrears)
        )

    cdef inline _frc.FloatingRateCoupon* _get_frc(self):
        return <_frc.FloatingRateCoupon*>self._thisptr.get()

    def set_pricer(self, FloatingRateCouponPricer pricer not None):
        self._get_frc().setPricer(pricer._thisptr)

    @property
    def fixing_days(self):
        return self._get_frc().fixingDays()

    @property
    def fixing_date(self):
        return date_from_qldate(self._get_frc().fixingDate())

    @property
    def index(self):
        cdef InterestRateIndex r = InterestRateIndex.__new__(InterestRateIndex)
        r._thisptr = self._get_frc().index()
        return r

    @property
    def index_fixing(self):
        return self._get_frc().indexFixing()

    @property
    def convexity_adjustment(self):
        return self._get_frc().convexityAdjustment()

    @property
    def adjusted_fixing(self):
        return self._get_frc().adjustedFixing()

    @property
    def is_in_arrears(self):
        return self._get_frc().isInArrears()
