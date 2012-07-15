"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _bonds

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp cimport bool as cbool

from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time._calendar cimport BusinessDayConvention
cimport quantlib.time._date as _date
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.time._schedule cimport Schedule as QlSchedule
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar import Following

import datetime

cdef class Bond:
    """ Base bond class

        .. warning:

            Most methods assume that the cash flows are stored
            sorted by date, the redemption(s) being after any
            cash flow at the same date. In particular, if there's
            one single redemption, it must be the last cash flow,

    """

    cdef shared_ptr[_bonds.Bond]* _thisptr
    cdef cbool _has_pricing_engine

    def __cinit__(self):
        self._thisptr = NULL
        self._has_pricing_engine = False

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def set_pricing_engine(self, PricingEngine engine):
        '''Sets the pricing engine.

        '''
        cdef shared_ptr[_pe.PricingEngine] engine_ptr = \
                shared_ptr[_pe.PricingEngine](deref(engine._thisptr))

        self._thisptr.get().setPricingEngine(engine_ptr)

        self._has_pricing_engine = True

    property issue_date:
        """ Bond issue date. """
        def __get__(self):
            cdef _date.Date issue_date = self._thisptr.get().issueDate()
            return date_from_qldate(issue_date)

    property maturity_date:
        """ Bond maturity date. """
        def __get__(self):
            cdef _date.Date maturity_date = self._thisptr.get().maturityDate()
            return date_from_qldate(maturity_date)

    property valuation_date:
        """ Bond valuation date. """
        def __get__(self):
            cdef _date.Date valuation_date = self._thisptr.get().valuationDate()
            return date_from_qldate(valuation_date)

    def settlement_date(self, Date from_date=None):
        """ Returns the bond settlement date after the given date."""
        cdef _date.Date* date
        cdef _date.Date settlement_date
        if from_date is not None:
            date = from_date._thisptr.get()
            settlement_date = self._thisptr.get().settlementDate(deref(date))
        else:
            settlement_date = self._thisptr.get().settlementDate()

        return date_from_qldate(settlement_date)

    property clean_price:
        """ Bond clena price. """
        def __get__(self):
            if self._has_pricing_engine:
                return self._thisptr.get().cleanPrice()

    property dirty_price:
        """ Bond dirty price. """
        def __get__(self):
            if self._has_pricing_engine:
                return self._thisptr.get().dirtyPrice()

    property net_present_value:
        """ Bond net present value. """
        def __get__(self):
            if self._has_pricing_engine:
                return self._thisptr.get().NPV()

    def accrued_amount(self, Date date=None):
        """ Returns the bond accrued amount at the given date. """
        if date is not None:
            amount = self._thisptr.get().accruedAmount(deref(date._thisptr.get()))
        else:
            amount = self._thisptr.get().accruedAmount()
        return amount

cdef class FixedRateBond(Bond):
    """ Fixed rate bond.

    Support:
        - simple annual compounding coupon rates

    Unsupported: (needs interfacing)
        - simple annual compounding coupon rates with internal schedule calculation
        - generic compounding and frequency InterestRate coupons
    """

    def __init__(self, int settlement_days, float face_amount,
            Schedule fixed_bonds_schedule,
            coupons, DayCounter accrual_day_counter,
            payment_convention=Following,
            float redemption=100.0, Date issue_date = None):

            # convert input type to internal structures
            cdef vector[Rate]* _coupons = new vector[Rate](len(coupons))
            for rate in coupons:
                _coupons.push_back(rate)

            cdef QlSchedule* _fixed_bonds_schedule = <QlSchedule*>fixed_bonds_schedule._thisptr
            cdef QlDayCounter* _accrual_day_counter = <QlDayCounter*>accrual_day_counter._thisptr

            cdef _date.Date* _issue_date

            if issue_date is None:
                # empty issue rate seem to break some of the computation with
                # segfaults. Do we really want to let the user do that ? Or
                # shall we default on the first date of the schedule ?
                self._thisptr = new shared_ptr[_bonds.Bond](
                    new _bonds.FixedRateBond(settlement_days,
                        face_amount, deref(_fixed_bonds_schedule), deref(_coupons),
                        deref(_accrual_day_counter),
                        <BusinessDayConvention>payment_convention,
                        redemption)
                )
            else:
                _issue_date = <_date.Date*>((<Date>issue_date)._thisptr.get())

                self._thisptr = new shared_ptr[_bonds.Bond](\
                    new _bonds.FixedRateBond(settlement_days,
                        face_amount, deref(_fixed_bonds_schedule),
                        deref(_coupons),
                        deref(_accrual_day_counter),
                        <BusinessDayConvention>payment_convention,
                        redemption, deref(_issue_date)
                    )
                )

cdef class ZeroCouponBond(Bond):
    """ Zero coupon bond. """

    def __init__(self, settlement_days, Calendar calendar, face_amount,
        Date maturity_date, payment_convention=Following, redemption=100.,
        Date issue_date=None
    ):
        """ Instantiate a zero coupon bond. """
        if issue_date is not None:
            self._thisptr = new shared_ptr[_bonds.Bond](
                new _bonds.ZeroCouponBond(
                    <Natural> settlement_days, deref(calendar._thisptr),
                    <Real>face_amount, deref(maturity_date._thisptr.get()),
                    <BusinessDayConvention>payment_convention,
                    <Real>redemption, deref(issue_date._thisptr.get())
                )
            )
        else:
            raise NotImplementedError(
                'Wrapper for such constructor not yet implemented.'
            )

