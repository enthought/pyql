from quantlib.types cimport Natural, Rate, Real, Spread
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp cimport bool
from quantlib.handle cimport static_pointer_cast
from quantlib.indexes.ibor_index cimport IborIndex
cimport quantlib.indexes._ibor_index as _ii
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following, Unadjusted
from quantlib.time.date cimport Date, Period
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.schedule cimport Schedule
from quantlib.utilities.null cimport Null

from . cimport _floatingratebond as _frb

cdef class FloatingRateBond(Bond):
    """ Floating rate bond """
    def __init__(self, Natural settlement_days, Real face_amount,
                 Schedule schedule, IborIndex ibor_index,
                 DayCounter accrual_day_counter, Natural fixing_days=Null[Natural](),
                 vector[Real] gearings=[1.], vector[Spread] spreads=[0.],
                 vector[Rate] caps=[], vector[Rate] floors=[],
                 BusinessDayConvention payment_convention=Following,
                 bool in_arrears=False,
                 Real redemption=100.0, Date issue_date=Date(),
                 Period ex_coupon_period=Period(),
                 Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False
        ):
        """ Floating rate bond

        Parameters
        ----------
        settlement_days : int
            Number of days before bond settles
        face_amount : float (C double in python)
            Amount of face value of bond
        float_schedule : Schedule
            Schedule of payments for bond
        ibor_index : IborIndex
            Ibor index
        accrual_day_counter: DayCounter
            dayCounter for Bond
        fixing_days : int
            Number of fixing days for bond
        gearings: list [float]
            Gearings defaulted to [1.]
        spreads: list [float]
            Spread on ibor index, default to [0.]
        caps: list [float]
            Caps on the spread
        floors: list[float]
            Floors on the spread
        payment_convention: BusinessDayConvention
            The business day convention for the payment schedule
        in_arrears: bool
        redemption : float
            Amount at redemption
        issue_date : Date
            Date bond was issued
        ex_coupon_period : Period
        ex_coupon_calendar : Calendar
        ex_coupon_convention: BusinessDayConvention
        ex_coupon_end_of_month: bool
        """

        self._thisptr.reset(
            new _frb.FloatingRateBond(
                settlement_days, face_amount,
                deref(schedule._thisptr),
                static_pointer_cast[_ii.IborIndex](ibor_index._thisptr),
                deref(accrual_day_counter._thisptr),
                payment_convention,
                fixing_days, gearings, spreads, caps, floors, in_arrears,
                redemption,
                deref(issue_date._thisptr),
                deref(ex_coupon_period._thisptr),
                ex_coupon_calendar._thisptr,
                ex_coupon_convention,
                ex_coupon_end_of_month
            )
        )
