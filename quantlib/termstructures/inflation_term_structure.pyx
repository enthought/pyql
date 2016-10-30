# Copyright (C) 2016, Enthought Inc
# Copyright (C) 2016, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'

from libcpp cimport bool

cimport quantlib.time._date as _date
from quantlib.time.date cimport Date, Period, date_from_qldate

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle

cimport quantlib.time._daycounter as _dc
from quantlib.time.daycounter cimport DayCounter

from quantlib.time._period cimport Frequency
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
        self._thisptr.linkTo(structure._thisptr.currentLink())

    cdef inline _if.InflationTermStructure* _get_term_structure(self):

        cdef shared_ptr[_if.InflationTermStructure] ts_ptr = \
            self._thisptr.currentLink()

        if ts_ptr.get() is NULL:
            raise ValueError('Inflation term structure not intialized')

        return ts_ptr.get()

    cdef bool _is_empty(self):

        return self._thisptr.empty()

    cdef _raise_if_empty(self):
        # verify that the handle is not empty. We could add an except + on the
        # definition of the currentLink() method but it creates more trouble on
        # the code generation with Cython than what it solves
        if self._is_empty():
            raise ValueError('Empty handle to the inflation term structure')

    property max_date:
        def __get__(self):
            self._raise_if_empty()
            cdef _if.InflationTermStructure* term_structure = \
              self._get_term_structure()
            cdef _date.Date max_date = term_structure.maxDate()
            return date_from_qldate(max_date)


cdef class ZeroInflationTermStructure(InflationTermStructure):

    def zeroRate(self, Date d,
                 Period inst_obs_lag,
                 bool force_linear_interpolation,
                 bool extrapolate):

        cdef _if.ZeroInflationTermStructure* term_structure = \
          <_if.ZeroInflationTermStructure*>self._get_term_structure()
        return term_structure.zeroRate(
            deref(d._thisptr.get()),
            deref(inst_obs_lag._thisptr.get()),
            force_linear_interpolation,
            extrapolate)

    def zeroRate(self, Time t,
                 bool extrapolate):

        cdef _if.ZeroInflationTermStructure* term_structure = \
          <_if.ZeroInflationTermStructure*>self._get_term_structure()
        return term_structure.zeroRate(t, extrapolate)

cdef class YoYInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        pass

    def yoyRate(self, Date d,
                Period inst_obs_lag,
                bool force_linear_interpolation,
                bool extrapolate):

        cdef _if.YoYInflationTermStructure* term_structure = \
          <_if.YoYInflationTermStructure*>self._get_term_structure()

        return term_structure.yoyRate(
            deref(d._thisptr.get()),
            deref(inst_obs_lag._thisptr.get()),
            force_linear_interpolation,
            extrapolate)

    def yoyRate(self, Time t,
                bool extrapolate):

        cdef _if.YoYInflationTermStructure* term_structure = \
          <_if.YoYInflationTermStructure*>self._get_term_structure()
        return term_structure.yoyRate(t, extrapolate)
