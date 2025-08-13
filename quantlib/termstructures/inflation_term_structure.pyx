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

from quantlib.time._period cimport Days

cimport quantlib.termstructures._inflation_term_structure as _if

cdef class InflationTermStructure(TermStructure):
    """Abstract Base Class.
    """

    @property
    def base_date(self):
        cdef _date.Date base_date = (<_if.InflationTermStructure*>self._thisptr.get()).baseDate()
        return date_from_qldate(base_date)

    @property
    def base_rate(self):
        return (<_if.InflationTermStructure*>self._thisptr.get()).baseRate()

cdef class ZeroInflationTermStructure(InflationTermStructure):

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
