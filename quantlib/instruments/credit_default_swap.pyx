# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
#

from quantlib.types cimport Natural, Rate, Real
from cython.operator cimport dereference as deref

from libcpp cimport bool

from quantlib.handle cimport shared_ptr, optional

cimport quantlib.instruments._credit_default_swap as _cds
cimport quantlib._instrument as _instrument
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.time._calendar as _calendar
cimport quantlib.time._schedule as _schedule

from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time.date cimport Date, Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.daycounters.simple cimport Actual360, Actual365Fixed
from quantlib.time.businessdayconvention cimport BusinessDayConvention

from quantlib.time.schedule cimport Schedule
from quantlib.cashflow cimport SimpleCashFlow
from quantlib.cashflows.fixed_rate_coupon cimport FixedRateLeg
from quantlib.time.date cimport _pydate_from_qldate
from quantlib.time._date cimport Date as QlDate

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
        last_period_day_counter : :class:`~quantlib.time.daycounter.DayCounter`, optional
            Day-count convention for accrual in last period
        rebates_accrual : bool, optional
            The protection seller pays the accrued scheduled current coupon at
            the start of the contract. The rebate date is not provided
            but computed to be two days after protection start.
        trade_date :  :class:`~quantlib.time.date.Date`
            The contract's trade date. It will be used with the ``cash_settlement_days`` to determine
            the date on which the cash settlement amount is paid. If not given, the trade date is
            guessed from the protection start date and ``schedule`` date generation rule.
        cash_settlement_days : int
            The number of business days from ``trade_date`` to cash settlement date.

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
                 DayCounter last_period_day_counter=Actual360(True),
                 bool rebates_accrual=True,
                 Date trade_date=Date(),
                 Natural cash_settlement_days=3):
        """Credit default swap as running-spread only"""

        self._thisptr = shared_ptr[_instrument.Instrument](
            new _cds.CreditDefaultSwap(
                side, notional, spread, deref(schedule._thisptr),
                payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr),
                shared_ptr[_cds.Claim](),
                deref(last_period_day_counter._thisptr),
                rebates_accrual,
                deref(trade_date._thisptr),
                cash_settlement_days)
        )

    @classmethod
    def from_upfront(cls, Side side, double notional, double upfront, double spread,
                     Schedule schedule not None, BusinessDayConvention payment_convention,
                     DayCounter day_counter not None, bool settles_accrual=True,
                     bool pays_at_default_time=True, Date protection_start=Date(),
                     Date upfront_date=Date(),
                     DayCounter last_period_day_counter=Actual360(True),
                     bool rebates_accrual=True,
                     Date trade_date=Date(),
                     Natural cash_settlement_days=3):
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
        upfront_date : :class:`~quantlib.time.date.Date`, optional
            Settlement date for the upfront and accrual
            rebate (if any) payments.
            Typically T+3, this is also the default value.
        last_period_day_counter : :class:`~quantlib.time.daycounter.DayCounter`, optional
            Day-count convention for accrual in last period
        rebates_accrual : bool, optional
            The protection seller pays the accrued scheduled current coupon at
            the start of the contract. The rebate date is not provided
            but computed to be two days after protection start.
        trade_date :  :class:`~quantlib.time.date.Date`
            The contract's trade date. It will be used with the `cash_settlement_days` to determine
            the date on which the cash settlement amount is paid. If not given, the trade date is
            guessed from the protection start date and `schedule` date generation rule.
        cash_settlement_days : int
            The number of business days from `trade_date` to cash settlement date.

        """
        cdef CreditDefaultSwap instance = CreditDefaultSwap.__new__(CreditDefaultSwap)
        instance._thisptr = shared_ptr[_instrument.Instrument](
            new _cds.CreditDefaultSwap(
                side, notional, upfront, spread, deref(schedule._thisptr),
                payment_convention,
                deref(day_counter._thisptr), settles_accrual, pays_at_default_time,
                deref(protection_start._thisptr),
                deref(upfront_date._thisptr),
                shared_ptr[_cds.Claim](),
                deref(last_period_day_counter._thisptr),
                rebates_accrual,
                deref(trade_date._thisptr),
                cash_settlement_days)
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
                            DayCounter dc=Actual365Fixed(),
                            PricingModel model=Midpoint):

        return _get_cds(self).conventionalSpread(recovery,
                                                 yts._thisptr,
                                                 deref(dc._thisptr),
                                                 <_cds.PricingModel>model)

    def implied_hazard_rate(self, Real target_npv, YieldTermStructure yts not None,
                            DayCounter dc=Actual365Fixed(),
                            Real recovery_rate=0.4,
                            Real accuracy=1e-8,
                            PricingModel model=Midpoint):

        return _get_cds(self).impliedHazardRate(target_npv,
                                                yts._thisptr,
                                                deref(dc._thisptr),
                                                recovery_rate,
                                                accuracy,
                                                <_cds.PricingModel>model)


def cds_maturity(Date trade_date, Period tenor, _schedule.Rule rule):
    """Computes a CDS maturity date.

    Parameters
    ----------
    trade_date : Date
    tenor : Period
    rule : Rule

    Returns
    -------
    datetime.date
        The maturity date. Returns None when a `rule` of CDS2015 and a `tenor` length of zero fail to yield a valid CDS maturity date.

    Raises
    ------
    ValueError

        - if the `rule` is not 'CDS2015', 'CDS' or 'OldCDS'.
        - if the `rule` is 'OldCDS' and a `tenor` of 0 months is provided. This restriction can be removed if 0M tenor was available before the CDS Big Bang 2009.
        - if the `tenor` is not a multiple of 3 months. For the avoidance of doubt, a `tenor` of 0 months is supported. """
    cdef QlDate r = _cds.cdsMaturity(deref(trade_date._thisptr), deref(tenor._thisptr), rule)
    if r == QlDate():
        return None
    else:
        return _pydate_from_qldate(r)
