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

    def link_to(self, InflationTermStructure structure):
        if not structure._thisptr.empty():
            self._thisptr.linkTo(structure._thisptr.currentLink())
        else:
            raise ValueError('structure not initialized')

    cdef _if.InflationTermStructure* _get_term_structure(self) except NULL:

        if not self._thisptr.empty():
            return self._thisptr.currentLink().get()
        else:
            raise ValueError('Inflation term structure not initialized')

    property max_date:
        def __get__(self):
            cdef _if.InflationTermStructure* term_structure = \
              self._get_term_structure()
            cdef _date.Date max_date = term_structure.maxDate()
            return date_from_qldate(max_date)

    @property
    def reference_date(self):
        cdef _if.InflationTermStructure* term_structure = \
              self._get_term_structure()
        cdef _date.Date reference_date = term_structure.referenceDate()
        return date_from_qldate(reference_date)

    @property
    def base_date(self):
        cdef _if.InflationTermStructure* term_structure = \
            self._get_term_structure()
        cdef _date.Date base_date = term_structure.baseDate()
        return date_from_qldate(base_date)

    @property
    def base_rate(self):
        return self._get_term_structure().baseRate()

    @property
    def index_is_interpolated(self):
        return self._get_term_structure().indexIsInterpolated()

    @property
    def observation_lag(self):
        cdef _if.InflationTermStructure* term_structure = \
            self._get_term_structure()
        return period_from_qlperiod(term_structure.observationLag())


cdef class ZeroInflationTermStructure(InflationTermStructure):

    def zero_rate(self, d, Period inst_obs_lag=Period(-1, Days),
                  bool force_linear_interpolation=False, bool extrapolate=False):


        cdef _if.ZeroInflationTermStructure* term_structure = \
          <_if.ZeroInflationTermStructure*>self._get_term_structure()

        if isinstance(d, Date):
            return term_structure.zeroRate(
                deref((<Date>d)._thisptr),
                deref(inst_obs_lag._thisptr),
                force_linear_interpolation,
                extrapolate)
        else:
            return term_structure.zeroRate(<Time?>d, extrapolate)

cdef class YoYInflationTermStructure(InflationTermStructure):


    def yoy_rate(self, d, Period inst_obs_lag=Period(-1, Days),
                bool force_linear_interpolation=False,
                bool extrapolate=False):

        cdef _if.YoYInflationTermStructure* term_structure = \
          <_if.YoYInflationTermStructure*>self._get_term_structure()

        if isinstance(d, Date):
            return term_structure.yoyRate(
                deref((<Date>d)._thisptr),
                deref(inst_obs_lag._thisptr),
                force_linear_interpolation,
                extrapolate)
        else:
            return term_structure.yoyRate(<Time?>d, extrapolate)
