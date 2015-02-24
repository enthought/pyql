"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

# Cython standard cimports
from cython.operator cimport dereference as deref
from cpython cimport bool
from libcpp cimport bool as cbool
from libcpp.string cimport string

# QuantLib header cimports
cimport quantlib.termstructures._yield_term_structure as _yts
cimport _libor
cimport quantlib._index as _in
from quantlib.time._calendar cimport BusinessDayConvention

# PyQL cimport
from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
from quantlib.currency.currency cimport Currency
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.util.compat cimport utf8_array_from_py_string


cdef class Libor(IborIndex):
    """ Base class for all BBA LIBOR indexes but the EUR, O/N, and S/N ones
    LIBOR fixed by BBA.

        See <http://www.bba.org.uk/bba/jsp/polopoly.jsp?d=225&a=1414>.
    """

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __init__(self,
        str familyName,
        Period tenor,
        Natural settlementDays,
        Currency currency,
        Calendar financial_center_calendar,
        DayCounter dayCounter,
        YieldTermStructure ts=None):

        # convert the Python str to C++ string
        cdef string familyName_string = utf8_array_from_py_string(familyName)

        cdef Handle[_yts.YieldTermStructure] ts_handle
        if ts is not None:
             ts_handle = deref(ts._thisptr.get())
        else:
            ts_handle = Handle[_yts.YieldTermStructure]()

        self._thisptr = new shared_ptr[_in.Index](
        new _libor.Libor(
            familyName_string,
            deref(tenor._thisptr.get()),
            <Natural> settlementDays,
            deref(currency._thisptr),
            deref(financial_center_calendar._thisptr),
            deref(dayCounter._thisptr),
            ts_handle))

