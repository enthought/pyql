from cython.operator cimport dereference as deref
from quantlib.types cimport Rate, Real, Spread
from quantlib.handle cimport optional, static_pointer_cast
from quantlib.cashflows.fixed_rate_coupon cimport FixedRateLeg
from quantlib.cashflows.ibor_coupon cimport IborLeg
from quantlib.indexes.ibor_index cimport IborIndex
cimport quantlib.indexes._ibor_index as _ib
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.time._schedule cimport Schedule as QlSchedule
from . cimport _vanillaswap
from .swap cimport SwapType
from .swap import SwapType as PySwapType
from ._swap cimport Swap as QlSwap

cdef inline _vanillaswap.VanillaSwap* get_vanillaswap(VanillaSwap swap):
    """ Utility function to extract a properly casted Swap pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    return <_vanillaswap.VanillaSwap*>swap._thisptr.get()

cdef class VanillaSwap(Swap):
    """
    Vanilla swap class
    """

    def __init__(self, SwapType type,
                 Real nominal,
                 Schedule fixed_schedule not None,
                 Rate fixed_rate,
                 DayCounter fixed_daycount not None,
                 Schedule float_schedule not None,
                 IborIndex ibor_index not None,
                 Spread spread,
                 DayCounter floating_daycount not None,
                 int payment_convention=-1):
        cdef optional[BusinessDayConvention] opt_payment_convention
        if payment_convention > 0:
            opt_payment_convention = <BusinessDayConvention>payment_convention

        self._thisptr.reset(
            new _vanillaswap.VanillaSwap(
                <QlSwap.Type>type,
                nominal,
                deref(fixed_schedule._thisptr),
                fixed_rate,
                deref(fixed_daycount._thisptr),
                deref(float_schedule._thisptr),
                static_pointer_cast[_ib.IborIndex](ibor_index._thisptr),
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
        return PySwapType(get_vanillaswap(self).type())

    @property
    def fixed_rate(self):
        return get_vanillaswap(self).fixedRate()

    @property
    def fixed_schedule(self):
        cdef Schedule sched = Schedule.__new__(Schedule)
        sched._thisptr = new QlSchedule(get_vanillaswap(self).fixedSchedule())
        return sched

    @property
    def fixed_day_count(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new QlDayCounter(get_vanillaswap(self).fixedDayCount())
        return dc

    @property
    def floating_schedule(self):
        cdef Schedule sched = Schedule.__new__(Schedule)
        sched._thisptr = new QlSchedule(get_vanillaswap(self).floatingSchedule())
        return sched

    @property
    def spread(self):
        return get_vanillaswap(self).spread()

    @property
    def floating_day_count(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new QlDayCounter(get_vanillaswap(self).floatingDayCount())
        return dc

    @property
    def npv_date_discount(self):
        return get_vanillaswap(self).npvDateDiscount()
