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
from quantlib.time._calendar cimport BusinessDayConvention
cimport quantlib.time._date as _date
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.time._schedule cimport Schedule as QlSchedule
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar import Following
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure \
        as ts
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

import datetime

cdef class Bond:

    cdef _bonds.Bond* _thisptr
    cdef cbool has_pricing_engine

    def __cinit__(self):
        self._thisptr = NULL
        self.has_pricing_engine = False

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def set_pricing_engine(self, YieldTermStructure yield_term_structure):
        '''Sets the pricing engine based on the given term structure.

        FIXME : the pricing engine is not exposed and cannot be selected at tis
        stage. There is only one engine for bonds, the DiscountingBondEngine,
        which is allocated when calling this function.
        '''
        cdef Handle[ts]* term_structure
        cdef YieldTermStructure ds = yield_term_structure
        if ds.relinkable:
            term_structure = ds._relinkable_ptr

        cdef _bonds.DiscountingBondEngine* engine = \
                new _bonds.DiscountingBondEngine(deref(term_structure))
        cdef shared_ptr[_bonds.PricingEngine]* engine_ptr = \
                new _bonds.shared_ptr[_bonds.PricingEngine](engine)

        self._thisptr.setPricingEngine(deref(engine_ptr))

        self.has_pricing_engine = True

    property issue_date:
        def __get__(self):
            cdef _date.Date issue_date = self._thisptr.issueDate()
            return date_from_qldate(issue_date)

    property maturity_date:
        def __get__(self):
            cdef _date.Date maturity_date = self._thisptr.maturityDate()
            return date_from_qldate(maturity_date)

    property valuation_date:
        def __get__(self):
            cdef _date.Date valuation_date = self._thisptr.valuationDate()
            return date_from_qldate(valuation_date)

    def settlement_date(self, Date from_date=None):
        cdef _date.Date* date
        cdef _date.Date settlement_date
        if from_date is not None:
            date = from_date._thisptr.get()
            settlement_date = self._thisptr.settlementDate(deref(date))
        else:
            settlement_date = self._thisptr.settlementDate()

        print settlement_date.year(), settlement_date.month(), settlement_date.dayOfMonth()

        return date_from_qldate(settlement_date)

    property clean_price:
        def __get__(self):
            if self.has_pricing_engine:
                return self._thisptr.cleanPrice()

    property dirty_price:
        def __get__(self):
            if self.has_pricing_engine:
                return self._thisptr.dirtyPrice()

    property net_present_value:
        def __get__(self):
            if self.has_pricing_engine:
                return self._thisptr.NPV()
            else:
                return None

    def accrued_amount(self, Date date=None):
        if date is not None:
            amount = self._thisptr.accruedAmount(deref(date._thisptr.get()))
        else:
            amount = (<_bonds.Bond*>self._thisptr).accruedAmount()
        return amount

cdef class FixedRateBond(Bond):

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
                self._thisptr = new _bonds.FixedRateBond(settlement_days,
                    face_amount, deref(_fixed_bonds_schedule), deref(_coupons),
                    deref(_accrual_day_counter),
                    <BusinessDayConvention>payment_convention,
                    redemption
                )
            else:
                _issue_date = <_date.Date*>((<Date>issue_date)._thisptr.get())

                self._thisptr = new _bonds.FixedRateBond(settlement_days,
                        face_amount, deref(_fixed_bonds_schedule),
                        deref(_coupons),
                        deref(_accrual_day_counter),
                        <BusinessDayConvention>payment_convention,
                        redemption, deref(_issue_date)
                )

cdef class ZeroCouponBond(Bond):

    def __init__(self, settlement_days, Calendar calendar, face_amount,
        Date maturity_date, payment_convention=Following, redemption=100.,
        Date issue_date=None
    ):
        if issue_date is not None:
            self._thisptr = new _bonds.ZeroCouponBond(
                <Natural> settlement_days, deref(calendar._thisptr),
                <Real>face_amount, deref(maturity_date._thisptr.get()),
                <BusinessDayConvention>payment_convention,
                <Real>redemption, deref(issue_date._thisptr.get())
            )
        else:
            raise NotImplementedError()

