"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

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

from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._interest_rate as _ir
cimport quantlib.termstructures._inflation_term_structure as _if
cimport quantlib.termstructures.inflation._seasonality as _se

from quantlib.termstructures.inflation.seasonality cimport Seasonality

cdef class InflationTermStructure:
    """Abstract Base Class.
    """
    def __cinit__(self):
        self.relinkable = False
        self._thisptr = NULL

    def __init__(self, relinkable=True):
        if relinkable:
            self.relinkable = True
            # Create a new RelinkableHandle to a InflationTermStructure within a
            # new shared_ptr
            self._thisptr = <shared_ptr[Handle[_if.InflationTermStructure]]*> new \
                shared_ptr[RelinkableHandle[_if.InflationTermStructure]](
                    new RelinkableHandle[_if.InflationTermStructure]()
                )
        else:
            self._thisptr = new shared_ptr[Handle[_if.InflationTermStructure]](
                new Handle[_if.InflationTermStructure]()
            )

    def link_to(self, InflationTermStructure structure):
        cdef RelinkableHandle[_if.InflationTermStructure]* rh
        if not self.relinkable:
            raise ValueError('Non relinkable inflation term structure !')
        else:
            rh = <RelinkableHandle[_if.InflationTermStructure]*>self._thisptr.get()
            rh.linkTo(
                structure._thisptr.get().currentLink()
            )

        return

    cdef _if.InflationTermStructure* _get_term_structure(self):

        cdef _if.InflationTermStructure* term_structure
        cdef shared_ptr[_if.InflationTermStructure] ts_ptr
        ts_ptr = shared_ptr[_if.InflationTermStructure](
                self._thisptr.get().currentLink()
        )
        term_structure = ts_ptr.get()

        if term_structure is NULL:
            raise ValueError('Inflation term structure not intialized')

        return term_structure

    cdef _is_empty(self):

        return self._thisptr.get().empty()

    cdef _raise_if_empty(self):
        # verify that the handle is not empty. We could add an except + on the
        # definition of the currentLink() method but it creates more trouble on
        # the code generation with Cython than what it solves
        if self._is_empty():
            raise ValueError('Empty handle to the inflation term structure')
        
    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    property max_date:
        def __get__(self):
            self._raise_if_empty()
            cdef _if.InflationTermStructure* term_structure = self._get_term_structure()
            cdef _date.Date max_date = term_structure.maxDate()
            return date_from_qldate(max_date)

        
cdef class ZeroInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        pass
    
    # def __init__(self,
    #              DayCounter day_counter,
    #              Rate baseZeroRate,
    #              Period lag,
    #              int frequency,
    #              bool indexIsInterpolated,
    #              YieldTermStructure yTS,
    #              Seasonality seasonality):
        
    #     cdef Handle[_ff.YieldTermStructure] yTS_handle = \
    #             deref(yTS._thisptr.get())

    #     cdef _dc.DayCounter* _day_counter = <_dc.DayCounter*>day_counter._thisptr

    #     cdef _if.ZeroInflationTermStructure* _zifts
        
    #     _zifts = new _if.ZeroInflationTermStructure(
    #             deref(_day_counter),
    #             <Real> baseZeroRate,
    #             deref(lag._thisptr.get()),
    #             <_ir.Frequency>frequency,
    #             indexIsInterpolated,
    #             yTS_handle,
    #             deref(seasonality._thisptr.get()))

    #     self._thisptr = new shared_ptr[Handle[_if.InflationTermStructure]](
    #          new Handle[_if.InflationTermStructure](shared_ptr[_if.InflationTermStructure](_zifts)))

    def zeroRate(self, Date d,
                 Period inst_obs_lag,
                 bool force_linear_interpolation,
                 bool extrapolate):
        
        cdef _if.ZeroInflationTermStructure* term_structure = <_if.ZeroInflationTermStructure*>self._get_term_structure()
        return term_structure.zeroRate(
            deref(d._thisptr.get()),
            deref(inst_obs_lag._thisptr.get()),
            force_linear_interpolation,
            extrapolate)

    def zeroRate(self, Time t,
                 bool extrapolate):

        cdef _if.ZeroInflationTermStructure* term_structure = <_if.ZeroInflationTermStructure*>self._get_term_structure()
        return term_structure.zeroRate(t, extrapolate)
        
cdef class YoYInflationTermStructure(InflationTermStructure):

    def __cinit__(self):
        pass
    
    # def __init__(self,
    #              DayCounter day_counter,
    #              Rate baseZeroRate,
    #              Period lag,
    #              Frequency frequency,
    #              bool indexIsInterpolated,
    #              YieldTermStructure yTS,
    #              Seasonality seasonality):
        
    #     cdef Handle[_ff.YieldTermStructure] yTS_handle = \
    #             deref(yTS._thisptr.get())

    #     cdef _dc.DayCounter* _day_counter = <_dc.DayCounter*>day_counter._thisptr

    #     cdef _if.YoYInflationTermStructure* _yoyifts

    #     _yoyifts = new _if.YoYInflationTermStructure(
    #             deref(_day_counter),
    #             <Real> baseZeroRate,
    #             deref(lag._thisptr.get()),
    #             <_ir.Frequency>frequency,
    #             indexIsInterpolated,
    #             yTS_handle,
    #             deref(seasonality._thisptr.get()))

    #     self._thisptr = new shared_ptr[Handle[_if.InflationTermStructure]](
    #          new Handle[_if.InflationTermStructure](shared_ptr[_if.InflationTermStructure](_yoyifts)))
        
    def yoyRate(self, Date d,
                Period inst_obs_lag,
                bool force_linear_interpolation,
                bool extrapolate):

        cdef _if.YoYInflationTermStructure* term_structure = <_if.YoYInflationTermStructure*>self._get_term_structure()

        return term_structure.yoyRate(
            deref(d._thisptr.get()),
            deref(inst_obs_lag._thisptr.get()),
            force_linear_interpolation,
            extrapolate)

    def yoyRate(self, Time t,
                bool extrapolate):

        cdef _if.YoYInflationTermStructure* term_structure = <_if.YoYInflationTermStructure*>self._get_term_structure()
        return term_structure.yoyRate(t, extrapolate)
