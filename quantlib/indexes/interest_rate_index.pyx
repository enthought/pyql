# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include '../types.pxi'
from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.string cimport string

from quantlib.index cimport Index
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency.currency cimport Currency
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate, period_from_qlperiod

cimport quantlib.currency._currency as _cu
cimport quantlib._index as _in
cimport quantlib.indexes._interest_rate_index as _iri
cimport quantlib.time._date as _dt
cimport quantlib.time._period as _pe
cimport quantlib.time._daycounter as _dc
cimport quantlib.time._calendar as _ca


cdef inline _iri.InterestRateIndex* get_iri(InterestRateIndex index):
    """ Utility function to extract a properly casted IRI pointer out of the
    internal _thisptr attribute of the Index base class. """
    return <_iri.InterestRateIndex*>index._thisptr.get()

cdef class InterestRateIndex(Index):

    def __str__(self):
        return 'Interest rate index %s' % self.name


    property family_name:
        def __get__(self):
            return get_iri(self).familyName().decode('utf-8')


    property tenor:
        def __get__(self):
            return period_from_qlperiod(get_iri(self).tenor())

    property fixing_days:
        def __get__(self):
            return int(get_iri(self).fixingDays())

    property day_counter:
        def __get__(self):
            cdef DayCounter dc = DayCounter.__new__(DayCounter)
            dc._thisptr = new _dc.DayCounter(get_iri(self).dayCounter())
            return dc

    @property
    def currency(self):
        cdef Currency curr = Currency.__new__(Currency)
        curr._thisptr = new _cu.Currency(get_iri(self).currency())
        return curr

    def fixing_date(self, Date valueDate not None):
        cdef _dt.Date dt = valueDate._thisptr
        cdef _dt.Date fixing_date = get_iri(self).fixingDate(dt)
        return date_from_qldate(fixing_date)


    def value_date(self, Date fixingDate not None):
        cdef _dt.Date dt = fixingDate._thisptr
        cdef _dt.Date value_date = get_iri(self).valueDate(dt)
        return date_from_qldate(value_date)

    def maturity_date(self, Date valueDate not None):
        cdef _dt.Date dt = valueDate._thisptr
        cdef _dt.Date maturity_date = get_iri(self).maturityDate(dt)
        return date_from_qldate(maturity_date)

    def forecast_fixing(self, Date fixing_date not None):
        cdef _dt.Date dt = fixing_date._thisptr
        return get_iri(self).forecastFixing(dt)
