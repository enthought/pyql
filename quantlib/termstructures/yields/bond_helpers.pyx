include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, static_pointer_cast

cimport quantlib.instruments._bonds as _bonds
cimport quantlib.time._calendar as _calendar
from . cimport _bond_helpers as _bh

from quantlib.instruments.bonds cimport Bond
from quantlib.quote cimport Quote
from quantlib.time.date cimport Date
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._businessdayconvention cimport Following
from quantlib.termstructures.yields.rate_helpers cimport RateHelper


cdef class BondHelper(RateHelper):

    def __init__(self, Quote clean_price, Bond bond not None):

        self._thisptr = shared_ptr[_bh.RateHelper](
            new _bh.BondHelper(
                clean_price.handle(),
                static_pointer_cast[_bonds.Bond](bond._thisptr)
            ))


cdef class FixedRateBondHelper(BondHelper):

    def __init__(self, Quote clean_price, Natural settlement_days,
                 Real face_amount, Schedule schedule not None,
                 vector[Rate] coupons,
                 DayCounter day_counter not None, int payment_conv=Following,
                 Real redemption=100.0, Date issue_date=Date()):

        self._thisptr = shared_ptr[_bh.RateHelper](
            new _bh.FixedRateBondHelper(
                clean_price.handle(),
                settlement_days,
                face_amount,
                deref(schedule._thisptr),
                coupons,
                deref(day_counter._thisptr),
                <_calendar.BusinessDayConvention> payment_conv,
                redemption,
                deref(issue_date._thisptr)
            ))
