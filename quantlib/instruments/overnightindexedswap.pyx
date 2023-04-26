"""Overnight index swap paying compounded overnight vs. fixed"""
from quantlib.types cimport Real
from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.cashflows.fixed_rate_coupon cimport FixedRateLeg
from quantlib.cashflows.overnight_indexed_coupon cimport OvernightLeg
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.cashflows.rateaveraging import RateAveraging as PyRateAveraging
from quantlib.types cimport Natural, Rate, Real, Spread
from quantlib.indexes.ibor_index cimport OvernightIndex
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following
from quantlib.time.calendar cimport Calendar
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.handle cimport make_shared, static_pointer_cast
from .swap cimport Swap
from .swap import SwapType as PySwapType
from quantlib._instrument cimport Instrument
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib._index as _ind
cimport quantlib.time._daycounter as _dc


cdef inline _ois.OvernightIndexedSwap* get_OIS(OvernightIndexedSwap self):
        return <_ois.OvernightIndexedSwap*>self._thisptr.get()

cdef class OvernightIndexedSwap(Swap):
    """Overnight indexed swap: fix vs compounded overnight rate"""
    def __init__(self, Type swap_type, nominal, Schedule schedule,
                 Rate fixed_rate, DayCounter fixed_dc, OvernightIndex overnight_index,
                 Spread spread=0.0, Natural payment_lag=0,
                 BusinessDayConvention payment_adjustment=Following,
                 Calendar payment_calendar=Calendar(), bool telescopic_value_dates=False,
                 RateAveraging averaging_method=RateAveraging.Compound):
        cdef vector[double] nominals
        cdef double n

        if isinstance(nominal, float):
            self._thisptr = static_pointer_cast[Instrument](
                make_shared[_ois.OvernightIndexedSwap](
                    swap_type, <Real>nominal, deref(schedule._thisptr), fixed_rate,
                    deref(fixed_dc._thisptr), static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                    spread, payment_lag, payment_adjustment, payment_calendar._thisptr,
                    telescopic_value_dates, averaging_method
                )
            )
        elif isinstance(nominal, list):
            for n in nominal:
                nominals.push_back(n)
            self._thisptr = static_pointer_cast[Instrument](
                make_shared[_ois.OvernightIndexedSwap](
                    swap_type, nominals, deref(schedule._thisptr), fixed_rate,
                    deref(fixed_dc._thisptr), static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                    spread, payment_lag, payment_adjustment, payment_calendar._thisptr,
                    telescopic_value_dates, averaging_method
                )
            )

    @property
    def type(self):
        return PySwapType(get_OIS(self).type())

    @property
    def nominal(self):
        return get_OIS(self).nominal()

    @property
    def nominals(self):
        return get_OIS(self).nominals()

    @property
    def payment_frequency(self):
        return get_OIS(self).paymentFrequency()

    @property
    def fixed_rate(self):
        return get_OIS(self).fixedRate()

    @property
    def fixed_day_count(self):
        cdef DayCounter d = DayCounter.__new__(DayCounter)
        d._thisptr = new _dc.DayCounter(get_OIS(self).fixedDayCount())
        return d

    @property
    def overnight_index(self):
        cdef OvernightIndex index = OvernightIndex.__new__(OvernightIndex)
        index._thisptr = static_pointer_cast[_ind.Index](get_OIS(self).overnightIndex())
        return index

    @property
    def averaging_method(self):
        return PyRateAveraging(get_OIS(self).averagingMethod())

    @property
    def fixed_leg_BPS(self):
        return get_OIS(self).fixedLegBPS()

    @property
    def fixed_leg_NPV(self):
        return get_OIS(self).fixedLegNPV()

    @property
    def fair_rate(self):
        return get_OIS(self).fairRate()

    @property
    def spread(self):
        return get_OIS(self).spread()

    @property
    def fair_spread(self):
        return get_OIS(self).fairSpread()

    @property
    def overnight_leg_BPS(self):
        return get_OIS(self).overnightLegBPS()

    @property
    def overnight_leg_NPV(self):
        return get_OIS(self).overnightLegNPV()

    @property
    def fixed_leg(self):
        cdef FixedRateLeg leg = FixedRateLeg.__new__(FixedRateLeg)
        leg._thisptr = get_OIS(self).fixedLeg()
        return leg

    @property
    def overnight_leg(self):
        cdef OvernightLeg leg = OvernightLeg.__new__(OvernightLeg)
        leg._thisptr = get_OIS(self).overnightLeg()
        return leg
