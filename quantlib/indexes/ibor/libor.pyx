"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

# Cython standard cimports
from cython.operator cimport dereference as deref
from cpython cimport bool
from libcpp cimport bool as cbool
from libcpp.string cimport string

# QuantLib header cimports
cimport quantlib.termstructures._yield_term_structure as _yts
from . cimport _libor
cimport quantlib._index as _in
cimport quantlib.time._calendar as _calendar

# PyQL cimport
from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.currency.currency cimport Currency
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter


cdef class Libor(IborIndex):
    """ Base class for all BBA LIBOR indexes but the EUR, O/N, and S/N ones
    LIBOR fixed by BBA.

        See <http://www.bba.org.uk/bba/jsp/polopoly.jsp?d=225&a=1414>.
    """

    def __init__(self,
        basestring familyName,
        Period tenor not None,
        Natural settlementDays,
        Currency currency not None,
        Calendar financial_center_calendar not None,
        DayCounter dayCounter not None,
        YieldTermStructure ts not None=YieldTermStructure()):

        # convert the Python str to C++ string
        cdef string familyName_string = familyName.encode('utf-8')

        self._thisptr = shared_ptr[_in.Index](
        new _libor.Libor(
            familyName_string,
            deref(tenor._thisptr),
            <Natural> settlementDays,
            deref(currency._thisptr),
            deref(financial_center_calendar._thisptr),
            deref(dayCounter._thisptr),
            ts._thisptr))

    @property
    def joint_calendar(self):
        cdef Calendar cal = Calendar.__new__(Calendar)
        cal._thisptr = new _calendar.Calendar((<_libor.Libor*>self._thisptr.get()).jointCalendar())
        return cal
