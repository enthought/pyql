"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _swap
cimport _vanillaswap
cimport _instrument
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.time._date as _date
cimport quantlib._cashflow as _cf
cimport quantlib.indexes._ibor_index as _ib

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.handle cimport Handle, shared_ptr, optional, make_optional
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.time._schedule cimport Schedule as QlSchedule
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.businessdayconvention import Following
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.cashflow cimport Leg
from quantlib.cashflows.fixed_rate_coupon cimport FixedRateLeg
from quantlib.cashflows.ibor_coupon cimport IborLeg

import datetime

cdef public enum SwapType:
    Payer    = _vanillaswap.Payer
    Receiver = _vanillaswap.Receiver


cdef inline _swap.Swap* get_swap(Swap swap):
    """ Utility function to extract a properly casted Swap pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    cdef _swap.Swap* ref = <_swap.Swap*>swap._thisptr.get()
    return ref


cdef class Swap(Instrument):
    """
    Base swap class
    """

    def __init__(self):
        raise NotImplementedError('Generic swap not yet implemented. \
        Please use child classes.')

    ## def __init__(self, Leg firstLeg,
    ##              Leg secondLeg):

    ##     cdef _cf.Leg* leg1 = firstLeg._thisptr.get()
    ##     cdef _cf.Leg* leg2 = secondLeg._thisptr.get()

    ##     self._thisptr = new shared_ptr[_instrument.Instrument](\
    ##        new _swap.Swap(deref(leg1),
    ##                       deref(leg2)))


    ## def __init__(self, vector[Leg] legs,
    ##          vector[bool] payer):

    ##     cdef vector[_cf.Leg]* _legs = new vector[_cf.Leg](len(legs))
    ##     for l in legs:
    ##         _legs.push_back(l)

    ##     cdef vector[bool]* _payer = new vector[bool](len(payer))
    ##     for p in payer:
    ##         _payer.push_back(p)

    ##     self._thisptr = new shared_ptr[_instrument.Instrument](\
    ##         new _swap.Swap(_legs, payer)
    ##         )

    property is_expired:
        def __get__(self):
            cdef bool is_expired = get_swap(self).isExpired()
            return is_expired

    property start_date:
        def __get__(self):
            cdef _date.Date dt = get_swap(self).startDate()
            return date_from_qldate(dt)

    property maturity_date:
        def __get__(self):
            cdef _date.Date dt = get_swap(self).maturityDate()
            return date_from_qldate(dt)

    def leg_BPS(self, Size j):
        return get_swap(self).legBPS(j)

    def leg_NPV(self, Size j):
        return get_swap(self).legNPV(j)

    ## def startDiscounts(self, Size j):
    ##     return get_swap(self).startDiscounts(j)

    ## def endDiscounts(self, Size j):
    ##     return get_swap(self).endDiscounts(j)

    ## def npvDateDiscount(self):
    ##     return get_swap(self).npvDateDiscount()

    def __getitem__(self, int i):
        cdef Leg leg = Leg.__new__(Leg)
        leg._thisptr = get_swap(self).leg(i)
        return leg

cdef inline _vanillaswap.VanillaSwap* get_vanillaswap(VanillaSwap swap):
    """ Utility function to extract a properly casted Swap pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    cdef _vanillaswap.VanillaSwap* ref = \
         <_vanillaswap.VanillaSwap*>swap._thisptr.get()
    return ref

cdef class VanillaSwap(Swap):
    """
    Vanilla swap class
    """

    def __init__(self, SwapType type,
                     Real nominal,
                     Schedule fixed_schedule,
                     Rate fixed_rate,
                     DayCounter fixed_daycount,
                     Schedule float_schedule,
                     IborIndex ibor_index,
                     Spread spread,
                     DayCounter floating_daycount,
                     payment_convention=None):
        cdef optional[BusinessDayConvention] opt_payment_convention = \
        make_optional[BusinessDayConvention](
            payment_convention is not None,
            <BusinessDayConvention>payment_convention)

        self._thisptr = new shared_ptr[_instrument.Instrument](
            new _vanillaswap.VanillaSwap(
                <_vanillaswap.Type>type,
                nominal,
                deref(fixed_schedule._thisptr),
                fixed_rate,
                deref(fixed_daycount._thisptr),
                deref(float_schedule._thisptr),
                deref(<shared_ptr[_ib.IborIndex]*> ibor_index._thisptr),
                spread,
                deref(floating_daycount._thisptr),
                opt_payment_convention
            )
        )

    property fair_rate:
        def __get__(self):
            cdef Rate res = get_vanillaswap(self).fairRate()
            return res

    property fair_spread:
        def __get__(self):
            cdef Spread res = get_vanillaswap(self).fairSpread()
            return res

    property fixed_leg_bps:
        def __get__(self):
            cdef Real res = get_vanillaswap(self).fixedLegBPS()
            return res

    property floating_leg_bps:
        def __get__(self):
            cdef Real res = get_vanillaswap(self).floatingLegBPS()
            return res

    property fixed_leg_npv:
        def __get__(self):
            cdef Real res = get_vanillaswap(self).fixedLegNPV()
            return res

    property floating_leg_npv:
        def __get__(self):
            cdef Real res = get_vanillaswap(self).floatingLegNPV()
            return res
    @property
    def fixed_leg(self):
        cdef FixedRateLeg leg = FixedRateLeg.__new__(FixedRateLeg)
        leg._thisptr = get_vanillaswap(self).fixedLeg()
        return leg

    @property
    def floating_leg(self):
        cdef IborLeg leg = IborLeg.__new__(IborLeg)
        leg._thisptr = get_vanillaswap(self).floatingLeg()
        return leg

    @property
    def nominal(self):
        return get_vanillaswap(self).nominal()

    @property
    def type(self):
        return get_vanillaswap(self).type()
