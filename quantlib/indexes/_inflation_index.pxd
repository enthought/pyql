"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string

from quantlib._index cimport Index
from quantlib.currency._currency cimport Currency
from quantlib.indexes._region cimport Region
from quantlib.handle cimport shared_ptr
from quantlib.indexes._interest_rate_index cimport InterestRateIndex
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period, Frequency
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter


cdef extern from 'ql/indexes/inflationindex.hpp' namespace 'QuantLib':

    cdef cppclass InflationIndex(Index):
        InflationIndex()
        InflationIndex(string& familyName,
                  Region& region,
                  bool revised,
                  bool interpolated,
                  Frequency frequency,
                  Period& availabilitiyLag,
                  Currency& currency) except +
        string familyName()
