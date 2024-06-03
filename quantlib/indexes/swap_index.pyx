# cython: c_string_type=unicode, c_string_encoding=ascii
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
from libcpp.string cimport string

from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.indexes.interest_rate_index cimport InterestRateIndex
from quantlib.instruments.vanillaswap cimport VanillaSwap
from quantlib.instruments.overnightindexedswap cimport OvernightIndexedSwap
from quantlib.indexes.ibor_index cimport IborIndex, OvernightIndex
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency.currency cimport Currency
from quantlib.time.date cimport Date
from quantlib.time.calendar cimport Calendar
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure, HandleYieldTermStructure
cimport quantlib.termstructures._yield_term_structure as _yts

cimport quantlib._index as _in
cimport quantlib._instrument as _instrument
from . cimport _swap_index as _si
from . cimport _ibor_index as _ii

cdef class SwapIndex(InterestRateIndex):

    def __str__(self):
        return 'Swap index %s' % self.name

    def __init__(self, string family_name, Period tenor not None, Natural settlement_days,
                 Currency currency, Calendar calendar not None,
                 Period fixed_leg_tenor not None,
                 int fixed_leg_convention, DayCounter fixed_leg_daycounter not None,
                 IborIndex ibor_index not None,
                 HandleYieldTermStructure discounting_term_structure=None):

        if discounting_term_structure is None:
            self._thisptr.reset(
                new _si.SwapIndex(
                    family_name,
                    deref(tenor._thisptr),
                    settlement_days,
                    deref(currency._thisptr),
                    calendar._thisptr,
                    deref(fixed_leg_tenor._thisptr),
                    <BusinessDayConvention> fixed_leg_convention,
                    deref(fixed_leg_daycounter._thisptr),
                    static_pointer_cast[_ii.IborIndex](ibor_index._thisptr)
                )
            )
        else:
            self._thisptr.reset(
                new _si.SwapIndex(
                    family_name,
                    deref(tenor._thisptr),
                    settlement_days,
                    deref(currency._thisptr),
                    calendar._thisptr,
                    deref(fixed_leg_tenor._thisptr),
                    <BusinessDayConvention> fixed_leg_convention,
                    deref(fixed_leg_daycounter._thisptr),
                    static_pointer_cast[_ii.IborIndex](ibor_index._thisptr),
                    discounting_term_structure.handle
                )
            )

    def underlying_swap(self, Date fixing_date not None):
        cdef _si.SwapIndex* swap_index = <_si.SwapIndex*>self._thisptr.get()
        cdef VanillaSwap swap = VanillaSwap.__new__(VanillaSwap)
        swap._thisptr = static_pointer_cast[_instrument.Instrument](
            swap_index.underlyingSwap(fixing_date._thisptr))
        return swap

    @property
    def ibor_index(self):
        cdef _si.SwapIndex* swap_index = <_si.SwapIndex*>self._thisptr.get()
        cdef IborIndex ibor_index = IborIndex.__new__(IborIndex)
        ibor_index._thisptr = static_pointer_cast[_in.Index](swap_index.iborIndex())
        return ibor_index

    @property
    def forwarding_term_structure(self):
        cdef YieldTermStructure yts = YieldTermStructure.__new__(YieldTermStructure)
        cdef _si.SwapIndex* swap_index = <_si.SwapIndex*>self._thisptr.get()
        if not swap_index.forwardingTermStructure().empty():
            yts._thisptr = (swap_index.
                            forwardingTermStructure().
                            currentLink())
            return yts
        else:
            raise RuntimeError("Cannot dereference empty handle")

    @property
    def discounting_term_structure(self):
        cdef YieldTermStructure yts = YieldTermStructure.__new__(YieldTermStructure)
        cdef _si.SwapIndex* swap_index = <_si.SwapIndex*>self._thisptr.get()
        if not swap_index.discountingTermStructure().empty():
            yts._thisptr = (swap_index.
                            discountingTermStructure().
                            currentLink())
            return yts
        else:
            raise RuntimeError("Cannot dereference empty handle")


cdef class OvernightIndexedSwapIndex(SwapIndex):
    def __init__(self, string family_name, Period tenor not None, Natural settlement_days,
                 Currency currency, OvernightIndex overnight_index not None,
                 bool telescopic_value_dates=False,
                 RateAveraging averaging_method=RateAveraging.Compound):
        self._thisptr.reset(
            new _si.OvernightIndexedSwapIndex(
                family_name,
                deref(tenor._thisptr),
                settlement_days,
                deref(currency._thisptr),
                static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                telescopic_value_dates,
                averaging_method,
            )
        )

    def underlying_swap(self, Date fixing_date not None):
        cdef _si.OvernightIndexedSwapIndex* swap_index = <_si.OvernightIndexedSwapIndex*>self._thisptr.get()
        cdef OvernightIndexedSwap swap = OvernightIndexedSwap.__new__(OvernightIndexedSwap)
        swap._thisptr = static_pointer_cast[_instrument.Instrument](
            <shared_ptr[_si.OvernightIndexedSwap]>swap_index.underlyingSwap(fixing_date._thisptr))
        return swap
