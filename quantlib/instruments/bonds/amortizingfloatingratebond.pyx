from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport static_pointer_cast
cimport quantlib.indexes._ibor_index as _ii
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.types cimport Natural, Integer, Real, Rate, Spread
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following, Unadjusted
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, Period
from quantlib.time.calendar cimport Calendar
from quantlib.utilities.null cimport Null
from . cimport _amortizingfloatingratebond as _afb

cdef class AmortizingFloatingRateBond(Bond):
    def __init__(self, Natural settlement_days, vector[Real] notional, Schedule schedule, IborIndex index, DayCounter accrual_day_counter,
                 BusinessDayConvention payment_convention = Following, Natural fixing_days = Null[Natural](), vector[Real] gearings = [1.0],
                 vector[Spread] spreads = [0.0],
                 vector[Rate] caps=[], vector[Rate] floors=[], bool in_arrears = False, Date issue_date = Date(),
                 Period ex_coupon_period = Period(), Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False,
                 vector[Real] redemptions=[100.0],
                 Integer payment_lag = 0):
        self._thisptr.reset(
            new _afb.AmortizingFloatingRateBond(
                settlement_days,
                notional, schedule._thisptr, static_pointer_cast[_ii.IborIndex](index._thisptr),
                deref(accrual_day_counter._thisptr), payment_convention, fixing_days, gearings,
                spreads, caps, floors, in_arrears, deref(issue_date._thisptr),
                deref(ex_coupon_period._thisptr), ex_coupon_calendar._thisptr,
                ex_coupon_convention, ex_coupon_end_of_month,
                redemptions,
                payment_lag
            )
        )
