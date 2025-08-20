# Copyright (C) 2016, Enthought Inc
# Copyright (C) 2016, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast

from libcpp cimport bool
from libcpp.string cimport string

from quantlib.index cimport Index
from quantlib.time.date cimport Period, period_from_qlperiod, date_from_qldate
from quantlib.time.frequency cimport Frequency
from quantlib.indexes.region cimport Region

from quantlib.currency.currency cimport Currency
from quantlib.termstructures.inflation_term_structure cimport \
    ZeroInflationTermStructure, YoYInflationTermStructure

cimport quantlib._index as _in
cimport quantlib.indexes._inflation_index as _ii
cimport quantlib.termstructures._inflation_term_structure as _its
cimport quantlib._interest_rate as _ir

cimport quantlib.time._period as _pe
cimport quantlib.currency._currency as _cu
cimport quantlib.indexes._region as _region

cdef class InflationIndex(Index):

    def __cinit__(self):
        pass

    property family_name:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.familyName()

    property frequency:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.frequency()

    property availability_lag:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return period_from_qlperiod(ref.availabilityLag())


    property currency:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            cdef Currency c = Currency.__new__(Currency)
            c._thisptr = new _cu.Currency(ref.currency())
            return c

    @property
    def region(self):
        cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
        cdef Region region = Region.__new__(Region)
        region._thisptr = new _region.Region(ref.region())
        return region

cdef class ZeroInflationIndex(InflationIndex):
    def __init__(self, str family_name,
                 Region region,
                 bool revised,
                 Frequency frequency,
                 Period availabilityLag,
                 Currency currency,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):

        # convert the Python str to C++ string
        cdef string c_family_name = family_name.encode('utf-8')

        self._thisptr = shared_ptr[_in.Index](
            new _ii.ZeroInflationIndex(
                c_family_name,
                deref(region._thisptr),
                revised,
                frequency,
                deref(availabilityLag._thisptr),
                deref(currency._thisptr),
                ts._handle))

    def zero_inflation_term_structure(self):
        cdef ZeroInflationTermStructure r = \
                ZeroInflationTermStructure.__new__(ZeroInflationTermStructure)
        r._thisptr = static_pointer_cast[_its.InflationTermStructure](
            (<_ii.ZeroInflationIndex*>(self._thisptr.get())).
            zeroInflationTermStructure().currentLink())

    @property
    def last_fixing_date(self):
        return date_from_qldate(
            (<_ii.ZeroInflationIndex*>(self._thisptr.get())).lastFixingDate()
        )


cdef class YoYInflationIndex(ZeroInflationIndex):
    def __init__(self, family_name, Region region, bool revised,
                 Frequency frequency,
                 Period availability_lag, Currency currency,
                 YoYInflationTermStructure ts=YoYInflationTermStructure()):

        cdef string c_family_name = family_name.encode('utf-8')

        self._thisptr = shared_ptr[_in.Index](
            new _ii.YoYInflationIndex(
                c_family_name, deref(region._thisptr), revised,
                frequency,
                deref(availability_lag._thisptr),
                deref(currency._thisptr), ts._handle))
