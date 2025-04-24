"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from libcpp cimport bool
from libcpp.string cimport string

from quantlib._index cimport Index
from quantlib.currency._currency cimport Currency
from quantlib.indexes._region cimport Region
from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._period cimport Period, Frequency
from quantlib.time._date cimport Date

cimport quantlib.termstructures._inflation_term_structure as _its

cdef extern from 'ql/indexes/inflationindex.hpp' namespace 'QuantLib' nogil:

    cdef cppclass CPI:
        enum InterpolationType:
            AsIndex
            Flat
            Linear

    cdef cppclass InflationIndex(Index):
        InflationIndex(string& familyName,
                  Region& region,
                  bool revised,
                  Frequency frequency,
                  Period& availabilitiyLag,
                  Currency& currency) except +
        string familyName()
        Region region()
        bool revised()
        Frequency frequency()
        Period availabilityLag()
        Currency currency()


    cdef cppclass ZeroInflationIndex(Index):
        ZeroInflationIndex(string& familyName,
                  Region& region,
                  bool revised,
                  Frequency frequency,
                  Period& availabilitiyLag,
                  Currency& currency,
                  Handle[_its.ZeroInflationTermStructure]& h) except +
        Handle[_its.ZeroInflationTermStructure] zeroInflationTermStructure()
        Date lastFixingDate()

    cdef cppclass YoYInflationIndex(InflationIndex):
        YoYInflationIndex(const string& familyName,
                          const Region& region,
                          bool revised,
                          Frequency frequency,
                          const Period& availabilityLag,
                          const Currency& currency,
                          const Handle[_its.YoYInflationTermStructure]& ts # = Handle<YoYInflationTermStructure>());
        ) except +
