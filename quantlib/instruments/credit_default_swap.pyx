# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
#

include '../types.pxi'

from cython.operator cimport dereference as deref

from libcpp cimport bool

from quantlib.handle cimport shared_ptr

cimport _credit_default_swap as _cds
cimport _instrument
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.time._calendar as _calendar

from quantlib.instruments.instrument cimport Instrument
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.schedule cimport Schedule

BUYER = _cds.Buyer
SELLER = _cds.Seller

cdef _cds.CreditDefaultSwap* _get_cds(CreditDefaultSwap cds):
    """ Utility function to extract a properly casted Bond pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    cdef _cds.CreditDefaultSwap* ref = <_cds.CreditDefaultSwap*>cds._thisptr.get()

    return ref

cdef class CreditDefaultSwap(Instrument):
    """Credit default swap as running-spread only

        Parameters
        ----------
        side : int or {BUYER, SELLER}
           Whether the protection is bought or sold.
        notional : float
            Notional value
        spread  : float
            Running spread in fractional units.
        schedule : :class:`~quantlib.time.schedule.Schedule`
            Coupon schedule.
        paymentConvention : int
            Business-day convention for
            payment-date adjustment.
        dayCounter : :class:`~quantlib.time.daycounter.DayCounter`
            Day-count convention for accrual.
        settlesAccrual : bool, optional
            Whether or not the accrued coupon is
            due in the event of a default.
        paysAtDefaultTime : bool, optional
            If set to True, any payments
            triggered by a default event are
            due at default time. If set to
            False, they are due at the end of
            the accrual period.
        protectionStart : :class:`~quantlib.time.date.Date`, optional
            The first date where a default
            event will trigger the contract.

        Notes
        -----
        This instrument currently assumes that the issuer did
        not default until today's date.

        .. warning::

            if ``Settings.include_reference_date_cashflows``
            is set to ``True``, payments occurring at the
            settlement date of the swap might be included in the
            NPV and therefore affect the fair-spread
            calculation. This might not be what you want.

    """


    def __init__(self, int side, double notional, double spread, Schedule schedule,
                 int payment_convention,
                 DayCounter day_counter, bool settles_accrual=True,
                 bool pays_at_default_time=True,
                 Date protection_start=Date()):
        """Credit default swap as running-spread only
        """

        self._thisptr = new shared_ptr[_instrument.Instrument](
            new _cds.CreditDefaultSwap(
                <_cds.Side>side, notional, spread, deref(schedule._thisptr),
                <_calendar.BusinessDayConvention>payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr.get())
            )
        )

    @classmethod
    def from_upfront(cls, int side, double notional, double upfront, double spread,
                     Schedule schedule not None, int payment_convention,
                     DayCounter day_counter not None, bool settles_accrual=True,
                     bool pays_at_default_time=True, Date protection_start=Date(),
                     Date upfront_date=Date()):
        """Credit default swap quoted as upfront and running spread

        Parameters
        ----------
        side : int or {BUYER, SELLER}
           Whether the protection is bought or sold.
        notional : float
            Notional value
        upront : float
            Upfront payment in fractional units.
        spread : float
            Running spread in fractional units.
        schedule : :class:`~quantlib.time.schedule.Schedule`
            Coupon schedule.
        paymentConvention : int
            Business-day convention for
            payment-date adjustment.
        dayCounter : :class:`~quantlib.time.daycounter.DayCounter`
            Day-count convention for accrual.
        settlesAccrual : bool, optional
            Whether or not the accrued coupon is
            due in the event of a default.
        paysAtDefaultTime : bool, optional
            If set to True, any payments
            triggered by a default event are
            due at default time. If set to
            False, they are due at the end of
            the accrual period.
        protectionStart : :class:`~quantlib.time.date.Date`, optional
            The first date where a default
            event will trigger the contract.
        """

        cdef CreditDefaultSwap instance = cls.__new__(cls)
        instance._thisptr = new shared_ptr[_instrument.Instrument](
            new _cds.CreditDefaultSwap(
                <_cds.Side>side, notional, upfront, spread, deref(schedule._thisptr),
                <_calendar.BusinessDayConvention>payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr.get()),
                deref(upfront_date._thisptr.get()))
        )
        return instance

    property fair_upfront:
        """ Returns the upfront spread that, given the running spread
            and the quoted recovery rate, will make the instrument
            have an NPV of 0.
        """
        def __get__(self):
            return _get_cds(self).fairUpfront()

    property fair_spread:
        """ Returns the running spread that, given the quoted recovery
            rate, will make the running-only CDS have an NPV of 0.

            Notes
            -----
            This calculation does not take any upfront into account, even if
            one was given.
        """
        def __get__(self):
            return _get_cds(self).fairSpread()


    property default_leg_npv:
        def __get__(self):
            return _get_cds(self).defaultLegNPV()

    property coupon_leg_npv:
        def __get__(self):
            return _get_cds(self).couponLegNPV()

    @property
    def upfront_bps(self):
        return _get_cds(self).upfrontBPS()

    @property
    def coupon_leg_bps(self):
        return _get_cds(self).couponLegBPS()

    @property
    def upfront_npv(self):
        return _get_cds(self).upfrontNPV()
