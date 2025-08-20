# Copyright (C) 2016, Enthought Inc
# Copyright (C) 2016, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.types cimport Rate
from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

cimport quantlib.termstructures.inflation._seasonality as _se

from libcpp cimport bool as cbool

from quantlib.time._period cimport Frequency
cimport quantlib.time._date as _date
from quantlib.time.date cimport Date, date_from_qldate


cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.inflation_term_structure cimport InflationTermStructure
cimport quantlib.termstructures._inflation_term_structure as _if

cimport quantlib._interest_rate as _ir

cdef class Seasonality:

    def correctZeroRate(self,
		    Date d,
		    Rate r,
		    InflationTermStructure iTS):

        return self._thisptr.get().correctZeroRate(
            d._thisptr,
            r,
            deref(iTS._thisptr))

    def correctYoYRate(self,
		    Date d,
		    Rate r,
		    InflationTermStructure iTS):

        return self._thisptr.get().correctYoYRate(
            d._thisptr,
            r,
            deref(iTS._thisptr))

    def isConsistent(self,
		    InflationTermStructure iTS):

        return self._thisptr.get().isConsistent(
            deref(iTS._thisptr))


cdef class MultiplicativePriceSeasonality(Seasonality):

    def __init__(self, Date d not None, Frequency frequency, vector[Rate] seasonality_factors):
        self._thisptr = shared_ptr[_se.Seasonality](
            new _se.MultiplicativePriceSeasonality(
                d._thisptr,
                frequency,
                seasonality_factors))

    def set(self, Date seasonality_base_date not None,
            Frequency frequency,
            vector[Rate] seasonality_factors):

        (<_se.MultiplicativePriceSeasonality*>self._thisptr.get()).set(
            seasonality_base_date._thisptr,
            frequency,
            seasonality_factors)

    property seasonality_base_date:
        def __get__(self):
            cdef _date.Date base_date = (<_se.MultiplicativePriceSeasonality*> self._thisptr.get()).seasonalityBaseDate()
            return date_from_qldate(base_date)

    property frequency:
        def __get__(self):
            return (<_se.MultiplicativePriceSeasonality*> self._thisptr.get()).frequency()

    property seasonality_factors:
        def __get__(self):
            return (<_se.MultiplicativePriceSeasonality*> self._thisptr.get()).seasonalityFactors()

    def seasonality_factor(self, Date d):
        return (<_se.MultiplicativePriceSeasonality*> self._thisptr.get()).seasonalityFactor(
            d._thisptr)

    def isConsistent(self, InflationTermStructure iTS):

        return self._thisptr.get().isConsistent(
            deref(iTS._thisptr))
