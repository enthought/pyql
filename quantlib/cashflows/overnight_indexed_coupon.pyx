from quantlib.types cimport Real, Spread

from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport make_shared, shared_ptr, static_pointer_cast
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.daycounter cimport DayCounter
from quantlib.indexes.ibor_index cimport OvernightIndex
cimport quantlib.indexes._ibor_index as _ii
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
                deref(payment_date._thisptr), nominal,
                deref(start_date._thisptr), deref(end_date._thisptr),
                static_pointer_cast[_ii.OvernightIndex](index._thisptr),
                gearing, spread,
                deref(ref_period_start._thisptr), deref(ref_period_end._thisptr),
                deref(day_counter._thisptr), telescopic_values, averaging_method
        )
