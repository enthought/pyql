# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'

cimport _bonds
cimport _instrument
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.time._date as _date

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp cimport bool
from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle, static_pointer_cast
from quantlib.instruments.instrument cimport Instrument
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time._businessdayconvention cimport (
    BusinessDayConvention, Following, Unadjusted )
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.time._schedule cimport Schedule as QlSchedule
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate, Period
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._period cimport Frequency
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes.inflation_index cimport ZeroInflationIndex

cimport quantlib._cashflow as _cashflow
cimport quantlib.cashflow as cashflow
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib.indexes._inflation_index as _inf

cpdef enum InterpolationType:
    AsIndex = _bonds.AsIndex
    Flat = _bonds.Flat
    Linear = _bonds.Linear

cdef inline _bonds.Bond* get_bond(Bond bond):
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

    def settlement_date(self, Date from_date=Date()):
        """ Returns the bond settlement date after the given date."""
        return date_from_qldate(get_bond(self).settlementDate(deref(from_date._thisptr)))

    property clean_price:
        """ Bond clena price. """
        def __get__(self):
            return get_bond(self).cleanPrice()

    property dirty_price:
        """ Bond dirty price. """
        def __get__(self):
            return get_bond(self).dirtyPrice()

    def clean_yield(self, Real clean_price, DayCounter dc not None,
            _bonds.Compounding comp, _bonds.Frequency freq,
            Date settlement_date not None, Real accuracy=1e-08,
            Size max_evaluations=100):
        """ Return the yield given a (clean) price and settlement date

        The default bond settlement is used if no date is given.

        This method is the original Bond.yield method in C++.
        Python does not allow us to use the yield statement as a method name.

        """
        return get_bond(self).clean_yield(
                clean_price, deref(dc._thisptr), comp,
                freq, deref(settlement_date._thisptr),
                accuracy, max_evaluations
            )

    def accrued_amount(self, Date date=Date()):
        """ Returns the bond accrued amount at the given date. """
        return get_bond(self).accruedAmount(deref(date._thisptr))

    @property
    def cashflows(self):
        """ cash flow stream as a Leg """
        cdef cashflow.Leg leg = cashflow.Leg.__new__(cashflow.Leg)
        leg._thisptr = get_bond(self).cashflows()
        return leg

cdef class FixedRateBond(Bond):
    """ Fixed rate bond.
    Support:
        - simple annual compounding coupon rates

    Unsupported: (needs interfacing)
        - simple annual compounding coupon rates with internal schedule calculation
        - generic compounding and frequency InterestRate coupons
    """

    def __init__(self, Natural settlement_days, Real face_amount,
            Schedule schedule, vector[Rate] coupons,
            DayCounter accrual_day_counter,
            BusinessDayConvention payment_convention=Following,
            Real redemption=100.0, Date issue_date=Date(),
            Calendar payment_calendar=Calendar(),
            Period ex_coupon_period=Period(),
            Calendar ex_coupon_calendar=Calendar(),
            BusinessDayConvention ex_coupon_convention=Unadjusted,
            bool ex_coupon_end_of_month=False):
            """ Fixed rate bond (constructor)

            Parameters
            ----------
            settlement_days : int
                Number of days before bond settles
            face_amount : float (C double in python)
                Amount of face value of bond
            schedule : Quantlib::Schedule
                Schedule of payments for bond
            coupons : list[float]
                Interest[s] to be acquired for bond.
            accrual_day_counter: Quantlib::DayCounter
                dayCounter for Bond
            payment_convention: Quantlib::BusinessDayConvention
                The business day convention for the payment schedule
            redemption : float
                Amount at redemption
            issue_date : Quantlib::Date
                Date bond was issued
            """

            self._thisptr = shared_ptr[_instrument.Instrument](
                new _bonds.FixedRateBond(settlement_days,
                                         face_amount,
                                         deref(schedule._thisptr),
                                         coupons,
                                         deref(accrual_day_counter._thisptr),
                                         payment_convention,
                                         redemption, deref(issue_date._thisptr),
                                         deref(payment_calendar._thisptr),
                                         deref(ex_coupon_period._thisptr),
                                         deref(ex_coupon_calendar._thisptr),
                                         ex_coupon_convention,
                                         ex_coupon_end_of_month)
            )

cdef class ZeroCouponBond(Bond):
    """ Zero coupon bond """
    def __init__(self, Natural settlement_days, Calendar calendar,
        Real face_amount, Date maturity_date not None,
        BusinessDayConvention payment_convention=Following,
        Real redemption=100.0, Date issue_date=Date()):
        """ Zero coupon bond (constructor)

        Parameters
        ----------
        settlement_days : int
            Number of days before bond settles
        calendar : Quantlib::Calendar
            Type of Calendar
        face_amount: float (C double in python)
            Amount of face value of bond
        maturity_date: Quantlib::Date
            Date bond matures (pays off)
        payment_convention : Quantlib::BusinessDayConvention
            The business day convention for the payment schedule
        redemption : float
            Amount at redemption
        issue_date : Quantlib::Date
            Date bond was issued"""

        self._thisptr = shared_ptr[_instrument.Instrument](
                new _bonds.ZeroCouponBond(settlement_days,
                    deref(calendar._thisptr), face_amount,
                    deref(maturity_date._thisptr),
                    payment_convention, redemption,
                    deref(issue_date._thisptr)
                )
            )

cdef class FloatingRateBond(Bond):
    """ Floating rate bond """
    def __init__(self, Natural settlement_days, Real face_amount,
        Schedule schedule, IborIndex ibor_index,
        DayCounter accrual_day_counter, Natural fixing_days,
        vector[Real] gearings=[1.], vector[Spread] spreads=[0.],
        vector[Rate] caps=[], vector[Rate] floors=[],
        BusinessDayConvention payment_convention=Following,
        bool in_arrears=True,
        Real redemption=100.0, Date issue_date=Date()
        ):
        """ Floating rate bond (constructor)

        Parameters
        ----------
        settlement_days : int
            Number of days before bond settles
        face_amount : float (C double in python)
            Amount of face value of bond
        float_schedule : Quantlib::Schedule
            Schedule of payments for bond
        ibor_index : Quantlib::IborIndex
            Ibor index
        accrual_day_counter: Quantlib::DayCounter
            dayCounter for Bond
        fixing_days : int
            Number of fixing days for bond
        gearings: list [float]
            Gearings defaulted to [1.]
        spreads: list [float]
            Spread on ibor index, default to [0.]
        caps: list [float]
            Caps on the spread
        floors: list[float]
            Floors on the spread
        payment_convention: Quantlib::BusinessDayConvention
            The business day convention for the payment schedule
        in_arrears: bool
        redemption : float
            Amount at redemption
        issue_date : Quantlib::Date
            Date bond was issued
        """

        self._thisptr = shared_ptr[_instrument.Instrument](
            new _bonds.FloatingRateBond(
                settlement_days, face_amount,
                deref(schedule._thisptr),
                static_pointer_cast[_ii.IborIndex](ibor_index._thisptr),
                deref(accrual_day_counter._thisptr),
                payment_convention,
                fixing_days, gearings, spreads, caps, floors, True,
                redemption,
                deref(issue_date._thisptr)
                )
            )

cdef class CPIBond(Bond):
    """ CPI bond """
    def __init__(self, Natural settlement_days, Real face_amount, bool growth_only,
                 Real baseCPI, Period observation_lag not None,
                 ZeroInflationIndex cpi_index not None,
                 InterpolationType observation_interpolation,
                 Schedule schedule, vector[Rate] coupons,
                 DayCounter accrual_day_counter,
                 BusinessDayConvention payment_convention=Following,
                 Date issue_date=Date(), Calendar payment_calendar=Calendar(),
                 Period ex_coupon_period=Period(), Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False):

        self._thisptr = shared_ptr[_instrument.Instrument](
            new _bonds.CPIBond(
                settlement_days, face_amount, growth_only, baseCPI,
                deref(observation_lag._thisptr),
                static_pointer_cast[_inf.ZeroInflationIndex](
                    cpi_index._thisptr),
                observation_interpolation,
                deref(schedule._thisptr), coupons,
                deref(accrual_day_counter._thisptr), payment_convention,
                deref(issue_date._thisptr),
                deref(payment_calendar._thisptr), deref(ex_coupon_period._thisptr),
                deref(ex_coupon_calendar._thisptr), ex_coupon_convention,
                ex_coupon_end_of_month)
            )
