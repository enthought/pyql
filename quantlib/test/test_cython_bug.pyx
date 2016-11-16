include '../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

from quantlib.instruments._bonds cimport FixedRateBond
from quantlib.time._date cimport (
    Date as QlDate, Date_todaysDate, Jul, August, September, Date_endOfMonth
)
from quantlib.time._period cimport Years, Period, Annual, Days
from quantlib.time._calendar cimport Calendar
from quantlib.time._businessdayconvention cimport (
        Unadjusted, ModifiedFollowing, Following
)
from quantlib.time.calendars._target cimport TARGET
from quantlib.time._schedule cimport Schedule, Backward
from quantlib.time.date cimport date_from_qldate, Date
from quantlib.time.daycounters._actual_actual cimport ISMA, ActualActual

cdef extern from "ql_settings.hpp" namespace "QuantLib":
    QlDate get_evaluation_date()
    void set_evaluation_date(QlDate& date)


def test_bond_schedule_today_cython():
    cdef QlDate today = Date_todaysDate()
    cdef Calendar calendar = TARGET()

    cdef FixedRateBond* bond = get_bond_for_evaluation_date(today)

    cdef QlDate s_date = calendar.advance(today, <Integer>3, Days, Following,
            False)
    cdef QlDate b_date = bond.settlementDate()

    cdef Date s1 = date_from_qldate(s_date)
    cdef Date s2 = date_from_qldate(b_date)

    return s1, s2


cdef FixedRateBond* get_bond_for_evaluation_date(QlDate& in_date):

    set_evaluation_date(in_date)

    # debugged evaluation date
    cdef QlDate evaluation_date = get_evaluation_date()
    cdef Date cython_evaluation_date = date_from_qldate(evaluation_date)
    print 'Current evaluation date', cython_evaluation_date



    cdef Calendar calendar = TARGET()
    cdef QlDate effective_date = QlDate(10, Jul, 2006)

    cdef QlDate termination_date = calendar.advance(
        effective_date, <Integer>10, Years, Unadjusted, False
    )

    cdef Natural settlement_days = 3
    cdef Real face_amount = 100.0
    cdef Real coupon_rate = 0.05
    cdef Real redemption = 100.0

    cdef Schedule fixed_bond_schedule = Schedule(
            effective_date,
            termination_date,
            Period(Annual),
            calendar,
            ModifiedFollowing,
            ModifiedFollowing,
            Backward,
            False
    )

    cdef QlDate issue_date = QlDate(10, Jul, 2006)

    cdef vector[Rate] coupons
    coupons.push_back(coupon_rate)

    cdef FixedRateBond* bond = new FixedRateBond(
            settlement_days,
		    face_amount,
		    fixed_bond_schedule,
		    coupons,
            ActualActual(ISMA),
		    Following,
            redemption,
            issue_date
    )

    return bond

def test_bond_schedule_anotherday_cython():

    cdef QlDate last_month = QlDate(30, August, 2011)
    cdef QlDate today = Date_endOfMonth(last_month)

    cdef FixedRateBond* bond = get_bond_for_evaluation_date(today)

    cdef Calendar calendar = TARGET()
    cdef QlDate s_date = calendar.advance(today, <Integer>3, Days, Following,
            False)
    cdef QlDate b_date = bond.settlementDate()

    cdef QlDate e_date = get_evaluation_date()

    print s_date.serialNumber()
    print b_date.serialNumber()

    cdef Date s1 = date_from_qldate(s_date)
    cdef Date s2 = date_from_qldate(b_date)
    cdef Date s3 = date_from_qldate(e_date)
    print s3

    return s1, s2
