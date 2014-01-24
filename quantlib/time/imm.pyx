"""
 Copyright (C) 2014, Enthought Inc
 Copyright (C) 2014, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from cython.operator cimport dereference as deref
from libcpp cimport bool
cimport quantlib.time._date as _date
cimport quantlib.time._imm as _imm

from quantlib.time.date cimport Date
from quantlib.time.date cimport date_from_qldate

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

# IMM Months
cdef public enum Month:
     F = _imm.F
     G = _imm.G
     H = _imm.H
     J = _imm.J
     K = _imm.K
     M = _imm.M
     N = _imm.N
     Q = _imm.Q
     U = _imm.U
     V = _imm.V
     X = _imm.X
     Z = _imm.Z

def is_IMM_date(Date dt, bool main_cycle=True):
    # returns whether or not the given date is an IMM date
    return _imm.isIMMdate(deref(dt._thisptr.get()), main_cycle)

def is_IMM_code(string imm_code, bool main_cycle=True):
    # returns whether or not the given string is an IMM code
    return _imm.isIMMcode(imm_code, main_cycle)

def code(Date imm_date):
    return  _imm.code(deref(imm_date._thisptr.get()))

def date(string imm_code, Date reference_date=Date()):
    cdef _date.Date tmp = _imm.date(imm_code, deref(reference_date._thisptr.get()))
    return date_from_qldate(tmp)

def next_date(*args):
    """
    next IMM date following the given date
    returns the 1st delivery date for next contract listed in the
    International Money Market section of the Chicago Mercantile
    Exchange.
    """

    cdef _date.Date tmp
    
    cdef Date dt = <Date> args[0]
    if len(args) < 2:
        main_cycle = True
    else:
        main_cycle = args[1]

    tmp =  _imm.nextDate(deref(dt._thisptr.get()), <bool>main_cycle)

    return date_from_qldate(tmp)
    
def next_code(Date dt, bool main_cycle=True):
    """
    //! next IMM code following the given date
    /*! returns the IMM code for next contract listed in the
        International Money Market section of the Chicago Mercantile
        Exchange.
    """
    return _imm.nextCode(deref(dt._thisptr.get()), main_cycle)

## def next_code(string imm_code, bool main_cycle=True, Date reference_date=Date()):
##     """
##     //! next IMM code following the given code
##     /*! returns the IMM code for next contract listed in the
##         International Money Market section of the Chicago Mercantile
##         Exchange.
##     """
##     return _imm.nextCode(imm_code, main_cycle,
##                          deref(reference_date._thisptr.get()))

    
