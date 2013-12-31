"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'

from cython.operator cimport dereference as deref
from quantlib.time.date cimport Date
from libcpp cimport bool


cdef class Index:

    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate Index')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    property name:
       def __get__(self):
           return self._thisptr.get().name().c_str()

    ## def fixingCalendar(self):
    ##     result = self._thisptr.get().fixingCalendar()
    ##     return result
    
    def isValidFixingDate(self, Date fixingDate):
        return self._thisptr.get().isValidFixingDate(
            deref(fixingDate._thisptr.get()))

    def fixing(self, Date fixingDate, bool forecastTodaysFixing):
        return self._thisptr.get().fixing(
            deref(fixingDate._thisptr.get()), forecastTodaysFixing)

    ## def addFixing(self, Date fixingDate, Real fixing, bool forceOverwrite):
    ##     self._thisptr.get().addFixing(
    ##         deref(fixingDate._thisptr.get()), fixing, forceOverwrite)
    ##     return 0
        
