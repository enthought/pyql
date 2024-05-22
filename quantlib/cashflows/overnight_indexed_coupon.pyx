from quantlib.types cimport Real, Spread

from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref, preincrement as preinc
from quantlib.handle cimport make_shared, shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as QlDate
from quantlib.time.daycounter cimport DayCounter
from quantlib.indexes.ibor_index cimport OvernightIndex
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib._cashflow as _cf
from .rateaveraging cimport RateAveraging
from . cimport _overnight_indexed_coupon as _oic

cdef class OvernightIndexedCoupon(FloatingRateCoupon):

    def __init__(self, Date payment_date not None, Real nominal,
                 Date start_date not None, Date end_date not None,
                 OvernightIndex index not None, Real gearing=1., Spread spread=0.,
                 Date ref_period_start=Date(), Date ref_period_end=Date(),
                 DayCounter day_counter=DayCounter(), bool telescopic_values= False,
                 RateAveraging averaging_method=RateAveraging.Compound):
        self._thisptr = make_shared[_oic.OvernightIndexedCoupon](
                payment_date._thisptr, nominal,
                start_date._thisptr, end_date._thisptr,
                static_pointer_cast[_ii.OvernightIndex](index._thisptr),
                gearing, spread,
                ref_period_start._thisptr, ref_period_end._thisptr,
                deref(day_counter._thisptr), telescopic_values, averaging_method
        )

    def fixing_dates(self):
        cdef:
            vector[QlDate].const_iterator it = (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).fixingDates().const_begin()
            Date date
            list l = []

        while it != (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).fixingDates().end():
            date = Date.__new__(Date)
            date._thisptr = deref(it)
            l.append(date)
            preinc(it)
        return l

    def dt(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).dt()

    def index_fixings(self):
        return (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).indexFixings()

    def value_dates(self):
        cdef:
            vector[QlDate].const_iterator it = (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).valueDates().const_begin()
            Date date
            list l = []

        while it != (<_oic.OvernightIndexedCoupon*>self._thisptr.get()).valueDates().end():
            date = Date.__new__(Date)
            date._thisptr = deref(it)
            l.append(date)
            preinc(it)
        return l
    
        
cdef class OvernightLeg(Leg):

    def __iter__(self):
        cdef OvernightIndexedCoupon oic
        cdef vector[shared_ptr[_cf.CashFlow]].iterator it = self._thisptr.begin()
        while it != self._thisptr.end():
            oic = OvernightIndexedCoupon.__new__(OvernightIndexedCoupon)
            oic._thisptr = deref(it)
            yield oic
            preinc(it)
