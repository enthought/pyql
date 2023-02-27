#
# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
#

include '../../types.pxi'
from cython.operator cimport dereference as deref
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, static_pointer_cast

cimport quantlib.termstructures.credit._credit_helpers as _ci
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.time._period cimport Frequency
from quantlib.time.dategeneration cimport DateGeneration
from quantlib.time._calendar cimport BusinessDayConvention


from quantlib.time.date cimport Period, date_from_qldate, Date
cimport quantlib.time._date as _date
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
cimport quantlib._quote as _qt
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.instruments.credit_default_swap cimport CreditDefaultSwap
cimport quantlib.instruments._credit_default_swap as _cds
from quantlib.instruments.credit_default_swap cimport PricingModel
cimport quantlib._instrument as _instrument
from quantlib.quote cimport Quote

cdef class CdsHelper:
    """Base default-probability bootstrap helper

    Parameters
    ----------
    tenor :  :class:`~quantlib.time.date.Period`
        CDS tenor.
    frequency :  Frequency
        Coupon frequency.
    settlementDays : Integer
        The number of days from today's date
        to the start of the protection period.
    paymentConvention : BusinessDayConvention
        The payment convention applied to
        coupons schedules, settlement dates
        and protection period calculations.

    """

    def set_term_structure(self, DefaultProbabilityTermStructure ts not None):
         self._thisptr.get().setTermStructure(ts._thisptr.get())

    @property
    def latest_date(self):
        cdef _date.Date d = self._thisptr.get().latestDate()
        return date_from_qldate(d)

    @property
    def implied_quote(self):
        return self._thisptr.get().impliedQuote()

    @property
    def quote(self):
        cdef shared_ptr[_qt.Quote] quote_ptr = \
            self._thisptr.get().quote().currentLink()
        return quote_ptr.get().value()

    def swap(self):
        cdef CreditDefaultSwap cds = CreditDefaultSwap.__new__(CreditDefaultSwap)
        cdef shared_ptr[_cds.CreditDefaultSwap] temp = (<_ci.CdsHelper*>self._thisptr.get()).swap()
        cds._thisptr = static_pointer_cast[_instrument.Instrument](temp)
        return cds

    @property
    def implied_quote(self):
        return self._thisptr.get().impliedQuote()

cdef class SpreadCdsHelper(CdsHelper):
    """Spread-quoted CDS hazard rate bootstrap helper.

    Parameters
    ----------
    running_spread : float
        Running spread of the CDS.
    tenor :  :class:`~quantlib.time.date.Period`
        CDS tenor.
    settlementDays : int
        The number of days from today's date
        to the start of the protection period.
    calendar: :class:`~quantlib.time.calendar.Calendar`
    frequency :  Frequency
        Coupon frequency.
    payment_convention : int
        The payment convention applied to
        coupons schedules, settlement dates
        and protection period calculations.
    date_generation_rule : int
    daycounter : :class:`~quantlib.time.daycounter.DayCounter`
    recovery_rate : float
    discount_curve : :class:`~quantlib.termstructures.yield_term_structure.YieldTermStructure`
    settles_accrual : bool, optional
    pays_at_default_time : bool, optional
    start_date: :class:`~quantlib.time.date.Date`
    lastperiod: :class:`~quantlib.time.daycounter.DayCounter`
    rebates_accrual : bool
    """

    def __init__(self, running_spread, Period tenor, Integer settlement_days,
                 Calendar calendar not None, int frequency,
                 int paymentConvention, DateGeneration date_generation_rule,
                 DayCounter daycounter, Real recovery_rate,
                 YieldTermStructure discount_curve=YieldTermStructure(),
                 bool settles_accrual=True,
                 bool pays_at_default_time=True,
                 Date start_date=Date(),
                 DayCounter lastperiod=DayCounter(),
                 bool rebates_accrual=True,
                 bool use_isda_engine=True,
                 PricingModel model=PricingModel.ISDA):
        """
        """
        if isinstance(running_spread, float):
            self._thisptr = shared_ptr[_ci.DefaultProbabilityHelper](
                new _ci.SpreadCdsHelper(
                    <Rate>running_spread, deref(tenor._thisptr),
                    settlement_days, calendar._thisptr,
                    <Frequency>frequency,
                    <BusinessDayConvention>paymentConvention, date_generation_rule,
                    deref(daycounter._thisptr),
                    recovery_rate, discount_curve._thisptr, settles_accrual,
                    pays_at_default_time,
                    deref(start_date._thisptr),
                    deref(lastperiod._thisptr),
                    rebates_accrual,
                    model)
                )
        elif isinstance(running_spread, Quote):
            self._thisptr = shared_ptr[_ci.DefaultProbabilityHelper](
                new _ci.SpreadCdsHelper(
                    (<Quote>running_spread).handle(), deref(tenor._thisptr),
                    settlement_days, calendar._thisptr,
                    <Frequency>frequency,
                    <BusinessDayConvention>paymentConvention, date_generation_rule,
                    deref(daycounter._thisptr),
                    recovery_rate, discount_curve._thisptr, settles_accrual,
                    pays_at_default_time,
                    deref(start_date._thisptr),
                    deref(lastperiod._thisptr),
                    rebates_accrual,
                    model)
            )
        else:
            raise TypeError("running_spread needs to be a float or a Quote Handle")

cdef class UpfrontCdsHelper(CdsHelper):
    """Upfront+running-quoted CDS hazard rate bootstrap helper. """

    def __init__(self, upfront, Rate running_spread, Period tenor not None,
                 Integer settlement_days, Calendar calendar not None, int frequency,
                 int paymentConvention, DateGeneration rule,
                 DayCounter daycounter not None, Real recovery_rate,
                 YieldTermStructure discount_curve=YieldTermStructure(),
                 Natural upfront_settlement_days=3,
                 bool settles_accrual=True,
                 bool pays_at_default_time=True,
                 Date start_date=Date(),
                 DayCounter lastperiod=DayCounter(),
                 bool rebates_accrual=True,
                 PricingModel model=PricingModel.ISDA):
        """
        """
        if isinstance(upfront, float):
            self._thisptr = shared_ptr[_ci.DefaultProbabilityHelper](
                new _ci.UpfrontCdsHelper(
                    <Rate>upfront, running_spread, deref(tenor._thisptr.get()),
                    settlement_days, calendar._thisptr, <Frequency>frequency,
                    <BusinessDayConvention>paymentConvention, rule,
                    deref(daycounter._thisptr),
                    recovery_rate, discount_curve._thisptr, upfront_settlement_days, settles_accrual,
                    pays_at_default_time,
                    deref(start_date._thisptr),
                    deref(lastperiod._thisptr),
                    rebates_accrual,
                    model)
            )
        elif isinstance(upfront, Quote):
            self._thisptr = shared_ptr[_ci.DefaultProbabilityHelper](
                new _ci.UpfrontCdsHelper(
                    (<Quote>upfront).handle(), running_spread, deref(tenor._thisptr),
                    settlement_days, calendar._thisptr, <Frequency>frequency,
                    <BusinessDayConvention>paymentConvention, rule,
                    deref(daycounter._thisptr),
                    recovery_rate, discount_curve._thisptr, upfront_settlement_days, settles_accrual,
                    pays_at_default_time,
                    deref(start_date._thisptr),
                    deref(lastperiod._thisptr),
                    rebates_accrual,
                    model)
            )
