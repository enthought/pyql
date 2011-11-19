include '../../types.pxi'

from cython.operator cimport dereference as deref

cimport _rate_helpers as _rh
from quantlib.handle cimport shared_ptr
from quantlib._quote cimport Quote
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period

from quantlib.time.calendar import ModifiedFollowing

cdef class RateHelper:


    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'Deallocting RateHelper'
            del self._thisptr

cdef class DepositRateHelper(RateHelper):

    def __init__(self, Rate quote, Period tenor, Natural fixing_days,
        Calendar calendar, int convention=ModifiedFollowing,
        end_of_month=True, DayCounter deposit_day_counter=None
    ):

        self._thisptr = new shared_ptr[_rh.RateHelper](
            new _rh.DepositRateHelper(
                quote,
                deref(tenor._thisptr.get()),
                <int>fixing_days,
                deref(calendar._thisptr),
                <_rh.BusinessDayConvention>convention,
                True,
                deref(deposit_day_counter._thisptr)
            )
        )

    property quote:
        def __get__(self):
            return self._thisptr.get().quote().currentLink().get().value()
