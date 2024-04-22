from quantlib.types cimport Natural, Real, Rate
from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, static_pointer_cast

cimport quantlib.time._calendar as _calendar
from . cimport _bond_helpers as _bh

from quantlib.instruments.bond cimport Bond, Type
cimport quantlib.instruments._bond as _bond
from quantlib.quote cimport Quote
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, Period
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following, Unadjusted
from quantlib.termstructures.yields.rate_helpers cimport RateHelper


cdef class BondHelper(RateHelper):

    def __init__(self, Quote clean_price, Bond bond not None, Type price_type=Type.Clean):

        self._thisptr = shared_ptr[_bh.RateHelper](
            new _bh.BondHelper(
                clean_price.handle(),
                static_pointer_cast[_bond.Bond](bond._thisptr),
                price_type
            )
        )


cdef class FixedRateBondHelper(BondHelper):

    def __init__(self, Quote clean_price, Natural settlement_days,
                 Real face_amount, Schedule schedule not None,
                 vector[Rate] coupons,
                 DayCounter day_counter not None, BusinessDayConvention payment_conv=Following,
                 Real redemption=100.0,
                 Date issue_date=Date(),
                 Calendar payment_calendar=Calendar(),
                 Period ex_coupon_period=Period(),
                 Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False,
                 Type price_type=Type.Clean):

        self._thisptr.reset(
            new _bh.FixedRateBondHelper(
                clean_price.handle(),
                settlement_days,
                face_amount,
                schedule._thisptr,
                coupons,
                deref(day_counter._thisptr),
                payment_conv,
                redemption,
                deref(issue_date._thisptr),
                payment_calendar._thisptr,
                deref(ex_coupon_period._thisptr),
                ex_coupon_calendar._thisptr,
                ex_coupon_convention,
                ex_coupon_end_of_month,
                price_type
            )
        )
