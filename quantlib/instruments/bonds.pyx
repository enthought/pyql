"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _bonds
cimport _instrument
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.time._date as _date

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle
from quantlib.instruments.instrument cimport Instrument
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.time._schedule cimport Schedule as QlSchedule
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar import Following

cimport quantlib._cashflow as _cashflow
cimport quantlib.cashflow as cashflow

import datetime


cdef _bonds.Bond* get_bond(Bond bond):
    """ Utility function to extract a properly casted Bond pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    cdef _bonds.Bond* ref = <_bonds.Bond*>bond._thisptr.get()

    return ref


cdef class Bond(Instrument):
    """ Base bond class

        .. warning:

            Most methods assume that the cash flows are stored
            sorted by date, the redemption(s) being after any
            cash flow at the same date. In particular, if there's
            one single redemption, it must be the last cash flow,

    """

    def __init__(self):
        raise NotImplementedError('Cannot instantiate a Bond. Please use child classes.')


    property issue_date:
        """ Bond issue date. """
        def __get__(self):
            cdef _date.Date issue_date = get_bond(self).issueDate()
            return date_from_qldate(issue_date)

    property maturity_date:
        """ Bond maturity date. """
        def __get__(self):
            cdef _date.Date maturity_date = get_bond(self).maturityDate()
            return date_from_qldate(maturity_date)

    property valuation_date:
        """ Bond valuation date. """
        def __get__(self):
            cdef _date.Date valuation_date = get_bond(self).valuationDate()
            return date_from_qldate(valuation_date)

    def settlement_date(self, Date from_date=None):
        """ Returns the bond settlement date after the given date."""
        cdef _date.Date* date
        cdef _date.Date settlement_date
        if from_date is not None:
            date = from_date._thisptr.get()
            settlement_date = get_bond(self).settlementDate(deref(date))
        else:
            settlement_date = get_bond(self).settlementDate()

        return date_from_qldate(settlement_date)

    property clean_price:
        """ Bond clena price. """
        def __get__(self):
            if self._has_pricing_engine:
                return get_bond(self).cleanPrice()

    property dirty_price:
        """ Bond dirty price. """
        def __get__(self):
            if self._has_pricing_engine:
                return get_bond(self).dirtyPrice()

    def clean_yield(self, Real clean_price, DayCounter dc, int comp, int freq,
            Date settlement_date=None, Real accuracy=10e-08,
            Size max_evaluations=100):
        """ Return the yield given a (clean) price and settlement date

        The default bond settlement is used if no date is given.

        This method is the original Bond.yield method in C++.
        Python does not allow us to use the yield statement as a method name.


        """
        if settlement_date is not None:
            return get_bond(self).clean_yield(
                clean_price, deref(dc._thisptr), <_bonds.Compounding>comp,
                <_bonds.Frequency>freq, deref(settlement_date._thisptr.get()),
                accuracy, max_evaluations
            )



    def accrued_amount(self, Date date=None):
        """ Returns the bond accrued amount at the given date. """
        if date is not None:
            amount = get_bond(self).accruedAmount(deref(date._thisptr.get()))
        else:
            amount = get_bond(self).accruedAmount()
        return amount

    property cashflows:
        """ cash flow stream as a Leg """
        def __get__(self):
            cdef _cashflow.Leg leg
            cdef object result
            leg = get_bond(self).cashflows()
            result = cashflow.leg_items(leg)
            return result

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
                self._thisptr = new shared_ptr[_instrument.Instrument](
                    new _bonds.FixedRateBond(settlement_days,
                        face_amount, deref(_fixed_bonds_schedule), deref(_coupons),
                        deref(_accrual_day_counter),
                        <BusinessDayConvention>payment_convention,
                        redemption)
                )
            else:
                _issue_date = <_date.Date*>((<Date>issue_date)._thisptr.get())

                self._thisptr = new shared_ptr[_instrument.Instrument](\
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
            self._thisptr = new shared_ptr[_instrument.Instrument](
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

