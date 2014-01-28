"""
 Copyright (C) 2014, Enthought Inc
 Copyright (C) 2014, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

# distutils: language = c++
# distutils: libraries = QuantLib

include '../types.pxi'

from libcpp cimport bool
from _date cimport Date

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()    

cdef extern from 'ql/time/imm.hpp' namespace "QuantLib::IMM":

    # Main cycle of the International %Money Market (a.k.a. %IMM) months
    cdef enum Month:
        F
        G
        H
        J
        K
        M
        N
        Q
        U
        V
        X
        Z

    # returns whether or not the given date is an IMM date
    cdef bool isIMMdate(Date& d, bool mainCycle)

    # returns whether or not the given string is an IMM code
    cdef bool isIMMcode(string& immCode, bool mainCycle)

    # returns the IMM code for the given date
    # (e.g. H3 for March 20th, 2013).
    # warning It raises an exception if the input
    # date is not an IMM date

    cdef string code(Date& immDate) except +

    # returns the IMM date for the given IMM code
    # (e.g. March 20th, 2013 for H3).
    # It raises an exception if the input
    # string is not an IMM code
    
    cdef Date date(string& immCode, Date& referenceDate) except +

    # next IMM date following the given date
    # returns the 1st delivery date for next contract listed in the
    #    International Money Market section of the Chicago Mercantile
    #    Exchange.
    
    cdef Date nextDate_dt "QuantLib::IMM::nextDate" (Date& d, bool mainCycle)

    # next IMM date following the given IMM code
    # returns the 1st delivery date for next contract listed in the
    # International Money Market section of the Chicago Mercantile
    # Exchange.

    cdef Date nextDate_str "QuantLib::IMM::nextDate" (string& immCode,
                       bool mainCycle,
                       Date& referenceDate)

    # next IMM code following the given date
    # returns the IMM code for next contract listed in the
    #    International Money Market section of the Chicago Mercantile
    #    Exchange.

    cdef string nextCode_dt "QuantLib::IMM::nextCode" (Date& d,
                         bool mainCycle)

    # next IMM code following the given code
    # returns the IMM code for next contract listed in the
    #    International Money Market section of the Chicago Mercantile
    #    Exchange.

    cdef string nextCode_str "QuantLib::IMM::nextCode" (string& immCode,
                         bool mainCycle,
                         Date& referenceDate)
