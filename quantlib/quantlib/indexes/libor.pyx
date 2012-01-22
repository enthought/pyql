"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from cython.operator cimport dereference as deref
from cpython cimport bool
from libcpp cimport bool as cbool

from libcpp.string cimport string
from cpython.string cimport PyString_AsString

cimport quantlib.termstructures.yields._flat_forward as _ffwd
cimport _euribor as _eu
cimport quantlib._index as _in
cimport quantlib.indexes._ibor_index as _ii

from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency cimport Currency
from quantlib.time.calendar cimport Calendar
from quantlib.time._calendar cimport BusinessDayConvention


cdef class Libor(IborIndex):
    def __cinit__(self):
       self._thisptr = NULL

    ## This dealloc makes python crash
    ## def __dealloc__(self):
    ##     if self._thisptr is not NULL:
    ##         del self._thisptr
            
    def __init__(self,
        str familyName,
        Period tenor,
        Natural settlementDays,
        Currency currency,
        Calendar fixingCalendar,
        BusinessDayConvention busDayConvention,
        bool endOfMonth,
        DayCounter dayCounter):
    
        # convert the Python str to C++ string
        cdef string familyName_string = string(PyString_AsString(familyName))

        
        self._thisptr = new shared_ptr[_in.Index](
        new _ii.IborIndex(
            familyName_string,
            deref(tenor._thisptr.get()),
            <Natural> settlementDays,
            deref(currency._thisptr),
            deref(fixingCalendar._thisptr),
            <BusinessDayConvention> busDayConvention,
            <cbool> endOfMonth,
            deref(dayCounter._thisptr)))

