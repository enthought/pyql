# Copyright (C) 2016, Enthought Inc
# Copyright (C) 2016, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'

from libcpp cimport bool

cimport quantlib.time._date as _date
from quantlib.time.date cimport Date, Period, date_from_qldate, period_from_qlperiod

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport static_pointer_cast

cimport quantlib.time._daycounter as _dc
from quantlib.time.daycounter cimport DayCounter

from quantlib.time._period cimport Frequency, Days
from quantlib.time.calendar cimport Calendar

from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._interest_rate as _ir
cimport quantlib.termstructures._inflation_term_structure as _if
cimport quantlib.termstructures.inflation._seasonality as _se

from quantlib.termstructures.inflation.seasonality cimport Seasonality

cdef class InflationTermStructure:
    """Abstract Base Class.
    """

    property max_date:
        def __get__(self):
            cdef _date.Date max_date = self._thisptr.get().maxDate()
            return date_from_qldate(max_date)

    @property
    def reference_date(self):
        cdef _date.Date reference_date = self._thisptr.get().referenceDate()
        return date_from_qldate(reference_date)

    @property
    def base_date(self):
        cdef _date.Date base_date = self._thisptr.get().baseDate()
        return date_from_qldate(base_date)

    @property
    def base_rate(self):
        return self._thisptr.get().baseRate()

    @property
    def observation_lag(self):
        return period_from_qlperiod(self._thisptr.get().observationLag())

cdef class ZeroInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        self._handle = RelinkableHandle[_if.ZeroInflationTermStructure](
            static_pointer_cast[_if.ZeroInflationTermStructure](self._thisptr))

    def link_to(self, ZeroInflationTermStructure structure):
        self._thisptr = structure._thisptr
        self._handle.linkTo(static_pointer_cast[_if.ZeroInflationTermStructure](
            structure._thisptr))

    def zero_rate(self, d, Period inst_obs_lag=Period(-1, Days),
                  bool force_linear_interpolation=False, bool extrapolate=False):


        cdef _if.ZeroInflationTermStructure* term_structure = \
          <_if.ZeroInflationTermStructure*>self._thisptr.get()

        if isinstance(d, Date):
            return term_structure.zeroRate(
                (<Date>d)._thisptr,
                deref(inst_obs_lag._thisptr),
                force_linear_interpolation,
                extrapolate)
        else:
            return term_structure.zeroRate(<Time?>d, extrapolate)

cdef class YoYInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        self._handle = RelinkableHandle[_if.YoYInflationTermStructure](
            static_pointer_cast[_if.YoYInflationTermStructure](self._thisptr))

    def link_to(self, YoYInflationTermStructure structure):
        self._thisptr = structure._thisptr
        self._handle.linkTo(static_pointer_cast[_if.YoYInflationTermStructure](
            structure._thisptr))

    def yoy_rate(self, d, Period inst_obs_lag=Period(-1, Days),
                 bool force_linear_interpolation=False,
                 bool extrapolate=False):

        cdef _if.YoYInflationTermStructure* term_structure = \
          <_if.YoYInflationTermStructure*>self._thisptr.get()

        if isinstance(d, Date):
            return term_structure.yoyRate(
                (<Date>d)._thisptr,
                deref(inst_obs_lag._thisptr),
                force_linear_interpolation,
                extrapolate)
        else:
            return term_structure.yoyRate(<Time?>d, extrapolate)
