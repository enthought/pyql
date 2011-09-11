include '../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

from quantlib.instruments._bonds cimport FixedRateBond
from quantlib.time._date cimport Date as QlDate, Date_todaysDate, Jul, August
from quantlib.time._period cimport Years, Period, Annual, Days
from quantlib.time._calendar cimport (
    Calendar, TARGET, Unadjusted, ModifiedFollowing, Following
)
from quantlib.time._schedule cimport Schedule, Backward
from quantlib.time.date cimport date_from_qldate_ref, Date
from quantlib.time.daycounters._actual_actual cimport ISMA, ActualActual

cdef extern from "quantlib/settings/ql_settings.hpp" namespace "QL":
    QlDate get_evaluation_date()
    void set_evaluation_date(QlDate& date)


def test_bond_schedule_today_cython():
    
    cdef QlDate today = Date_todaysDate()
    set_evaluation_date(today)

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

    cdef vector[Rate]* coupons = new vector[Rate]()
    coupons.push_back(coupon_rate)

    cdef FixedRateBond* bond = new FixedRateBond(
            settlement_days,
		    face_amount,
		    fixed_bond_schedule,
		    deref(coupons),
            ActualActual(ISMA), 
		    Following,
            redemption,
            issue_date
    )

    cdef QlDate s_date = calendar.advance(today, <Integer>3, Days, Following,
            False)
    cdef QlDate b_date = bond.settlementDate()

    cdef Date s1 = date_from_qldate_ref(s_date)
    cdef Date s2 = date_from_qldate_ref(b_date)

    return s1, s2

def test_bond_schedule_anotherday_cython():
    
    cdef QlDate today = QlDate(30, August, 2011)
    set_evaluation_date(today)

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

    cdef vector[Rate]* coupons = new vector[Rate]()
    coupons.push_back(coupon_rate)

    cdef FixedRateBond* bond = new FixedRateBond(
            settlement_days,
	    face_amount,
	    fixed_bond_schedule,
	    deref(coupons),
            ActualActual(ISMA), 
	    Following,
            redemption,
            issue_date
    )

    cdef QlDate s_date = calendar.advance(today, <Integer>3, Days, Following,
            False)
    cdef QlDate b_date = bond.settlementDate()
	
    print s_date.serialNumber()
    print b_date.serialNumber()

    cdef Date s1 = date_from_qldate_ref(s_date)
    cdef Date s2 = date_from_qldate_ref(b_date)

    return s1, s2
