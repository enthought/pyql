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

from quantlib.handle cimport shared_ptr, optional

cimport quantlib.instruments._credit_default_swap as _cds
cimport quantlib.instruments._instrument as _instrument
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.time._calendar as _calendar

from quantlib.instruments.instrument cimport Instrument
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.daycounters.simple cimport Actual360, Actual365Fixed
from quantlib.time._businessdayconvention cimport BusinessDayConvention

from quantlib.time.schedule cimport Schedule
from quantlib.cashflow cimport SimpleCashFlow
from quantlib.cashflows.fixed_rate_coupon cimport FixedRateLeg
from quantlib.time.date cimport _pydate_from_qldate

cpdef enum Side:
    Buyer = _cds.Buyer
    Seller = _cds.Seller

cpdef enum PricingModel:
    Midpoint = _cds.Midpoint
    ISDA = _cds.ISDA

cdef inline _cds.CreditDefaultSwap* _get_cds(CreditDefaultSwap cds):
    """ Utility function to extract a properly casted Bond pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    return <_cds.CreditDefaultSwap*>cds._thisptr.get()

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
        payment_convention : int
            Business-day convention for
            payment-date adjustment.
        day_counter : :class:`~quantlib.time.daycounter.DayCounter`
            Day-count convention for accrual.
        settles_accrual : bool, optional
            Whether or not the accrued coupon is
            due in the event of a default.
        pays_at_default_time : bool, optional
            If set to True, any payments
            triggered by a default event are
            due at default time. If set to
            False, they are due at the end of
            the accrual period.
        protection_start : :class:`~quantlib.time.date.Date`, optional
            The first date where a default
            event will trigger the contract.
        upfront_date : :class`~quantlib.time.date.Date`
            Settlement date for the upfront and accrual
            rebate (if any) payments.
            Typically T+3, this is also the default value.
        last_period_day_counter : :class1~quantlib.time.daycounter.DayCounter`, optional
            Day-count convention for accrual in last period
        rebates_accrual : bool, optional
            The protection seller pays the accrued scheduled current coupon at
            the start of the contract. The rebate date is not provided
            but computed to be two days after protection start.

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

    def __init__(self, Side side, double notional, double spread,
                 Schedule schedule not None, BusinessDayConvention payment_convention,
                 DayCounter day_counter not None, bool settles_accrual=True,
                 bool pays_at_default_time=True,
                 Date protection_start=Date(),
                 DayCounter last_period_day_counter = Actual360(True),
                 bool rebates_accrual=True):
        """Credit default swap as running-spread only
        """

        self._thisptr = shared_ptr[_instrument.Instrument](
            new _cds.CreditDefaultSwap(
                side, notional, spread, deref(schedule._thisptr),
                payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr),
                shared_ptr[_cds.Claim](),
                deref(last_period_day_counter._thisptr),
                rebates_accrual)
        )

    @classmethod
    def from_upfront(cls, Side side, double notional, double upfront, double spread,
                     Schedule schedule not None, BusinessDayConvention payment_convention,
                     DayCounter day_counter not None, bool settles_accrual=True,
                     bool pays_at_default_time=True, Date protection_start=Date(),
                     Date upfront_date=Date(),
                     DayCounter last_period_day_counter=Actual360(True),
                     bool rebates_accrual=True):
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
        upfront_date : :class:`~quantlib.time.date.Date`, optionl
            Settlement date for the upfront and accrual
            rebate (if any) payments.
            Typically T+3, this is also the default value.
        """
        cdef CreditDefaultSwap instance = cls.__new__(cls)
        instance._thisptr = shared_ptr[_instrument.Instrument](
            new _cds.CreditDefaultSwap(
                side, notional, upfront, spread, deref(schedule._thisptr),
                payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr),
                deref(upfront_date._thisptr),
                shared_ptr[_cds.Claim](),
                deref(last_period_day_counter._thisptr),
                rebates_accrual)
        )
        return instance

    @property
    def side(self):
         return _get_cds(self).side()

    @property
    def notional(self):
        return _get_cds(self).notional()

    @property
    def running_spread(self):
         return _get_cds(self).runningSpread()

    @property
    def upfront(self):
        cdef optional[Rate] upf = _get_cds(self).upfront()
        return None if not upf else upf.get()

    @property
    def settles_accrual(self):
        return _get_cds(self).settlesAccrual()

    @property
    def pays_at_default_time(self):
        return _get_cds(self).paysAtDefaultTime()

    @property
    def coupons(self):
        cdef FixedRateLeg leg = FixedRateLeg.__new__(FixedRateLeg)
        leg._thisptr = _get_cds(self).coupons()
        return leg

    @property
    def protection_start_date(self):
        return _pydate_from_qldate(_get_cds(self).protectionStartDate())

    @property
    def protection_end_date(self):
        return _pydate_from_qldate(_get_cds(self).protectionEndDate())

    @property
    def rebates_accrual(self):
         return _get_cds(self).rebatesAccrual()

    @property
    def accrual(self):
        cdef SimpleCashFlow cf = SimpleCashFlow.__new__(SimpleCashFlow)
        cf._thisptr = _get_cds(self).accrualRebate()
        return cf

    @property
    def trade_date(self):
        return _pydate_from_qldate(_get_cds(self).tradeDate())

    @property
    def cash_settlement_days(self):
        return _get_cds(self).cashSettlementDays()

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

    @property
    def accrual_rebate_npv(self):
        return  _get_cds(self).accrualRebateNPV()

    def conventional_spread(self, Real recovery, YieldTermStructure yts not None,
                            PricingModel model=Midpoint):

        cdef DayCounter dc = Actual365Fixed()
        return _get_cds(self).conventionalSpread(recovery,
                                                 yts._thisptr,
                                                 deref(dc._thisptr),
                                                 <_cds.PricingModel>model)

    def implied_hazard_rate(self, Real target_npv, YieldTermStructure yts not None,
                            Real recovery_rate=0.4,
                            Real accuracy=1e-8,
                            PricingModel model=Midpoint):

        cdef DayCounter dc = Actual365Fixed()
        return _get_cds(self).impliedHazardRate(target_npv,
                                                yts._thisptr,
                                                deref(dc._thisptr),
                                                recovery_rate,
                                                accuracy,
                                                <_cds.PricingModel>model)
