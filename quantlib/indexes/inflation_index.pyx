# Copyright (C) 2016, Enthought Inc
# Copyright (C) 2016, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'

from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.string cimport string

from quantlib.index cimport Index
from quantlib.time.date cimport Period, period_from_qlperiod, date_from_qldate
from quantlib.time.frequency cimport Frequency
from quantlib.indexes.region cimport Region

from quantlib.currency.currency cimport Currency
from quantlib.handle cimport (
    Handle, HandleZeroInflationTermStructure, HandleYoYInflationTermStructure
)

cimport quantlib._index as _in
cimport quantlib.indexes._inflation_index as _ii
cimport quantlib._interest_rate as _ir

cimport quantlib.time._period as _pe
cimport quantlib.currency._currency as _cu
cimport quantlib.indexes._region as _region
from quantlib.termstructures._inflation_term_structure cimport ZeroInflationTermStructure, YoYInflationTermStructure

cdef class InflationIndex(Index):
    """Base class for inflation-rate indexes."""

    def __cinit__(self):
        pass

    property family_name:
        """The family name of the inflation index."""
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.familyName()

    property frequency:
        """The publication frequency of the inflation index."""
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.frequency()

    property availability_lag:
        """The availability lag of the index.

        The availability lag describes when the index might be
        available; for instance, the inflation value for January
        may only be available in April.
        """
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return period_from_qlperiod(ref.availabilityLag())


    property currency:
        """The currency of the inflation index."""
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            cdef Currency c = Currency.__new__(Currency)
            c._thisptr = new _cu.Currency(ref.currency())
            return c

    @property
    def region(self):
        """The region of the index."""
        cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
        cdef Region region = Region.__new__(Region)
        region._thisptr = new _region.Region(ref.region())
        return region

cdef class ZeroInflationIndex(InflationIndex):
    """Base class for zero-inflation indexes.

    Parameters
    ----------
    family_name : str
        The family name of the index.
    region : :class:`~quantlib.indexes.region.Region`
        The region of the index.
    revised : bool
        Whether the index is revised.
    frequency : :class:`~quantlib.time.frequency.Frequency`
        The frequency of the index.
    availabilityLag : :class:`~quantlib.time.date.Period`
        The availability lag of the index.
    currency : :class:`~quantlib.currency.currency.Currency`
        The currency of the index.
    ts : :class:`~quantlib.termstructures.inflation_term_structure.ZeroInflationTermStructure`, optional
        The zero-inflation term structure.
    """
    def __init__(self, str family_name,
                 Region region,
                 bool revised,
                 Frequency frequency,
                 Period availabilityLag,
                 Currency currency,
                 HandleZeroInflationTermStructure ts=HandleZeroInflationTermStructure()):
        # convert the Python str to C++ string
        cdef string c_family_name = family_name.encode('utf-8')

        self._thisptr.reset(
            new _ii.ZeroInflationIndex(
                c_family_name,
                deref(region._thisptr),
                revised,
                frequency,
                deref(availabilityLag._thisptr),
                deref(currency._thisptr),
                ts.handle())
        )

    @property
    def zero_inflation_term_structure(self):
        """Returns the zero-inflation term structure associated with the index."""
        cdef HandleZeroInflationTermStructure r = \
            HandleZeroInflationTermStructure.__new__(HandleZeroInflationTermStructure)
        r._handle = new Handle[ZeroInflationTermStructure](
            (<_ii.ZeroInflationIndex*>(self._thisptr.get())).zeroInflationTermStructure()
        )
        return r

    @property
    def last_fixing_date(self):
        """Returns the last date for which a fixing was provided."""
        return date_from_qldate(
            (<_ii.ZeroInflationIndex*>(self._thisptr.get())).lastFixingDate()
        )


cdef class YoYInflationIndex(ZeroInflationIndex):
    """Base class for year-on-year inflation indexes.

    These may be quoted indices published on, say, Bloomberg, or can be
    defined as the ratio of an index at different time points.

    Parameters
    ----------
    family_name : str
        The family name of the index.
    region : :class:`~quantlib.indexes.region.Region`
        The region of the index.
    revised : bool
        Whether the index is revised.
    frequency : :class:`~quantlib.time.frequency.Frequency`
        The frequency of the index.
    availability_lag : :class:`~quantlib.time.date.Period`
        The availability lag of the index.
    currency : :class:`~quantlib.currency.currency.Currency`
        The currency of the index.
    ts : :class:`~quantlib.termstructures.inflation_term_structure.YoYInflationTermStructure`, optional
        The year-on-year inflation term structure.
    """
    def __init__(self, family_name, Region region, bool revised,
                 Frequency frequency,
                 Period availability_lag, Currency currency,
                 HandleYoYInflationTermStructure ts=HandleYoYInflationTermStructure()):
        cdef string c_family_name = family_name.encode('utf-8')

        self._thisptr.reset(
            new _ii.YoYInflationIndex(
                c_family_name, deref(region._thisptr), revised,
                frequency,
                deref(availability_lag._thisptr),
                deref(currency._thisptr), ts.handle())
        )

    @property
    def yoy_inflation_term_structure(self):
        cdef HandleYoYInflationTermStructure r = \
            HandleYoYInflationTermStructure.__new__(HandleYoYInflationTermStructure)
        r._handle = new Handle[YoYInflationTermStructure](
            (<_ii.YoYInflationIndex*>(self._thisptr.get())).yoyInflationTermStructure()
        )
        return r
