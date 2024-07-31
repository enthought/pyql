"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.types cimport Rate

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.time._date cimport Date
from quantlib.time._period cimport Frequency

from .._inflation_term_structure cimport InflationTermStructure

cdef extern from 'ql/termstructures/inflation/seasonality.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Seasonality:
        Seasonality()
        Rate correctZeroRate(Date &d,
                             Rate r,
                             InflationTermStructure& iTS)
        Rate correctYoYRate(Date &d,
                            Rate r,
                            InflationTermStructure& iTS)
        bool isConsistent(InflationTermStructure& iTS)

    cdef cppclass MultiplicativePriceSeasonality(Seasonality):
        MultiplicativePriceSeasonality()
        MultiplicativePriceSeasonality(Date& seasonalityBaseDate,
                                       Frequency frequency,
                                       vector[Rate] seasonalityFactors)

        void set(Date& seasonalityBaseDate,
            Frequency frequency,
            vector[Rate] seasonalityFactors)

        # inspectors
        Date seasonalityBaseDate()
        Frequency frequency()
        vector[Rate] seasonalityFactors()
        Rate seasonalityFactor(Date &d)

        bool isConsistent(InflationTermStructure& iTS)
