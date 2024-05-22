from cython.operator cimport dereference as deref

from quantlib.types cimport Natural, Real
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date

from . cimport _zerocouponbond as _zcb

cdef class ZeroCouponBond(Bond):
    """ Zero coupon bond """
    def __init__(self, Natural settlement_days, Calendar calendar,
                 Real face_amount, Date maturity_date,
                 BusinessDayConvention payment_convention=Following,
                 Real redemption=100.0, Date issue_date=Date()):
        """ Zero coupon bond (constructor)

        Parameters
        ----------
        settlement_days : int
            Number of days before bond settles
        calendar : Calendar
            Type of Calendar
        face_amount: float (C double in python)
            Amount of face value of bond
        maturity_date: Date
            Date bond matures (pays off)
        payment_convention : BusinessDayConvention
            The business day convention for the payment schedule
        redemption : float
            Amount at redemption
        issue_date : Date
            Date bond was issued"""

        self._thisptr.reset(
            new _zcb.ZeroCouponBond(
                settlement_days, calendar._thisptr,
                face_amount,
                maturity_date._thisptr,
                payment_convention, redemption,
                issue_date._thisptr
            )
        )
