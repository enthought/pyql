from cython.operator cimport dereference as deref

from quantlib.types cimport Natural, Real, Rate
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following, Unadjusted
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period, Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.schedule cimport Schedule

from libcpp cimport bool
from libcpp.vector cimport vector
from . cimport _fixedratebond as _frb

cdef class FixedRateBond(Bond):
    """ Fixed rate bond.

    Support:
        - simple annual compounding coupon rates

    Unsupported: (needs interfacing)
        - simple annual compounding coupon rates with internal schedule calculation
        - generic compounding and frequency InterestRate coupons
    """

    def __init__(self, Natural settlement_days, Real face_amount,
                 Schedule schedule, vector[Rate] coupons,
                 DayCounter accrual_day_counter,
                 BusinessDayConvention payment_convention=Following,
                 Real redemption=100.0, Date issue_date=Date(),
                 Calendar payment_calendar=Calendar(),
                 Period ex_coupon_period=Period(),
                 Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False):
        """ Fixed rate bond

        Parameters
        ----------
        settlement_days : int
           Number of days before bond settles
        face_amount : float (C double in python)
           Amount of face value of bond
        schedule : Schedule
           Schedule of payments for bond
        coupons : list[float]
           Interest[s] to be acquired for bond.
        accrual_day_counter: DayCounter
           dayCounter for Bond
        payment_convention: BusinessDayConvention
           The business day convention for the payment schedule
        redemption : float
           Amount at redemption
        issue_date : Date
           Date bond was issued
        """

        self._thisptr.reset(
            new _frb.FixedRateBond(
                settlement_days,
                face_amount,
                deref(schedule._thisptr),
                coupons,
                deref(accrual_day_counter._thisptr),
                payment_convention,
                redemption, deref(issue_date._thisptr),
                payment_calendar._thisptr,
                deref(ex_coupon_period._thisptr),
                ex_coupon_calendar._thisptr,
                ex_coupon_convention,
                ex_coupon_end_of_month
            )
        )
