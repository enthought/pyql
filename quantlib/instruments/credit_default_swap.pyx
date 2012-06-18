"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from cython.operator cimport dereference as deref

from libcpp cimport bool

from quantlib.handle cimport shared_ptr

cimport _credit_default_swap as _cds
from quantlib.pricingengines cimport _pricing_engine as _pe
from quantlib.time cimport _calendar

from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.schedule cimport Schedule

BUYER = _cds.Buyer
SELLER = _cds.Seller

cdef class CreditDefaultSwap:
    """Credit default swap

        .. note::

            This instrument currently assumes that the issuer did
              not default until today's date.

        ..warning::

            if Settings.includeReferenceDateCashFlows()
            is set to <tt>true</tt>, payments occurring at the
            settlement date of the swap might be included in the
            NPV and therefore affect the fair-spread
            calculation. This might not be what you want.

    """


    cdef shared_ptr[_cds.CreditDefaultSwap]* _thisptr
    cdef public bool has_pricing_engine

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL


    def __init__(self, int side, float notional, float spread, Schedule schedule,
                 int payment_convention,
                 DayCounter day_counter, bool settles_accrual=True,
                 bool pays_at_default_time=True,
                 Date protection_start=Date()):
        """ CDS quoted as running-spread only

            @param side  Whether the protection is bought or sold.
            @param notional  Notional value
            @param spread  Running spread in fractional units.
            @param schedule  Coupon schedule.
            @param paymentConvention  Business-day convention for
                                      payment-date adjustment.
            @param dayCounter  Day-count convention for accrual.
            @param settlesAccrual  Whether or not the accrued coupon is
                                   due in the event of a default.
            @param paysAtDefaultTime  If set to true, any payments
                                      triggered by a default event are
                                      due at default time. If set to
                                      false, they are due at the end of
                                      the accrual period.
            @param protectionStart  The first date where a default
                                    event will trigger the contract.
        """

        self._thisptr = new shared_ptr[_cds.CreditDefaultSwap](
            new _cds.CreditDefaultSwap(
                <_cds.Side>side, notional, spread, deref(schedule._thisptr),
                <_calendar.BusinessDayConvention>payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr.get())
            )
        )

    def set_pricing_engine(self, PricingEngine engine):
        '''Sets the pricing engine for the CDS. '''

        cdef shared_ptr[_pe.PricingEngine] engine_ptr = \
                shared_ptr[_pe.PricingEngine](
                    deref(engine._thisptr)
                )

        self._thisptr.get().setPricingEngine(engine_ptr)
        self.has_pricing_engine = True

    property net_present_value:
        """ Option net present value. """
        def __get__(self):
            if self.has_pricing_engine:
                return self._thisptr.get().NPV()


    property fair_upfront:
        """ Returns the upfront spread that, given the running spread
            and the quoted recovery rate, will make the instrument
            have an NPV of 0.
        """
        def __get__(self):
            return self._thisptr.get().fairUpfront()

    property fair_spread:
        """ Returns the running spread that, given the quoted recovery
            rate, will make the running-only CDS have an NPV of 0.

            .. note::

                This calculation does not take any upfront into account, even if
                one was given.
        """
        def __get__(self):
            return self._thisptr.get().fairSpread()


    property default_leg_npv:
        def __get__(self):
            return self._thisptr.get().defaultLegNPV()

    property coupon_leg_npv:
        def __get__(self):
            return self._thisptr.get().couponLegNPV()


