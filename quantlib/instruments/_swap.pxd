"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle
from _instrument cimport Instrument
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib._cashflow cimport Leg

cdef extern from 'ql/instruments/swap.hpp' namespace 'QuantLib':
    cdef cppclass Swap(Instrument):

        ## Swap(Leg& firstLeg,
        ##      Leg& secondLeg)

        ## Swap(vector[Leg]& legs,
        ##      vector[bool]& payer)
        
        bool isExpired()
        Date startDate()
        Date maturityDate()
        Real legBPS(Size j)
        Real legNPV(Size j)
        Leg& leg(Size j)

