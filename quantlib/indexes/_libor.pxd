"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp.string cimport string

from quantlib.handle cimport Handle
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.currency._currency cimport Currency
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period


cdef extern from 'ql/indexes/ibor/libor.hpp' namespace 'QuantLib':

    cdef cppclass Libor(IborIndex):
        Libor()
        Libor(string& familyName,
                  Period& tenor,
                  Natural settlementDays,
                  Currency& currency,
                  Calendar& finencialCenterCalendar,
                  DayCounter& dayCounter,
                  Handle[_yts.YieldTermStructure]& h) except +
        
