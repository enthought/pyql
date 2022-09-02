"""Simple fixed-rate vs Libor swap"""
from cython.operator cimport dereference as deref
from quantlib.types cimport Rate, Real, Spread
from quantlib.handle cimport optional, static_pointer_cast
from quantlib.indexes.ibor_index cimport IborIndex
cimport quantlib.indexes._ibor_index as _ib
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from . cimport _vanillaswap
from .swap cimport Type

cdef inline _vanillaswap.VanillaSwap* get_vanillaswap(VanillaSwap swap):
    """ Utility function to extract a properly casted Swap pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    return <_vanillaswap.VanillaSwap*>swap._thisptr.get()

cdef class VanillaSwap(FixedVsFloatingSwap):
    """
    Vanilla swap class
    """

    def __init__(self, Type type,
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
                type,
                nominal,
                fixed_schedule._thisptr,
                fixed_rate,
                deref(fixed_daycount._thisptr),
                float_schedule._thisptr,
                static_pointer_cast[_ib.IborIndex](ibor_index._thisptr),
                spread,
                deref(floating_daycount._thisptr),
                opt_payment_convention
            )
        )
