"""
 Copyright (C) 2014, Enthought Inc
 Copyright (C) 2014, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.string cimport string
cimport quantlib.time._date as _date
cimport quantlib.time._imm as _imm

from quantlib.time.date cimport Date
from quantlib.time.date cimport date_from_qldate


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

def is_IMM_code(char* imm_code, bool main_cycle=True):
    # returns whether or not the given string is an IMM code
    cdef object _code = imm_code
    return _imm.isIMMcode(<str> _code, main_cycle)

def code(Date imm_date):
    return  _imm.code(deref(imm_date._thisptr.get()))

def date(char* imm_code, Date reference_date=Date()):
    cdef object _code = imm_code
    cdef _date.Date tmp = _imm.date(<str>_code, deref(reference_date._thisptr.get()))
    return date_from_qldate(tmp)

def next_date(code_or_date, main_cycle=True, Date reference_date=Date()):
    """ Next IMM date following the given date

    returns the 1st delivery date for next contract listed in the
    International Money Market section of the Chicago Mercantile
    Exchange.
    """

    cdef _date.Date result

    cdef Date dt
    cdef object _code


    if isinstance(code_or_date, str):
        result =  _imm.nextDate_str(
            <str> code_or_date, <bool>main_cycle,
            deref(reference_date._thisptr.get())
        )
    else:
        dt = <Date> code_or_date
        result =  _imm.nextDate_dt(deref(dt._thisptr.get()), <bool>main_cycle)

    return date_from_qldate(result)

def next_code(code_or_date, main_cycle=True, Date reference_date=Date()):
    """ Next IMM code following the given date or code

    Returns the IMM code for next contract listed in the
    International Money Market section of the Chicago Mercantile Exchange.
    """

    cdef Date dt

    if(isinstance(code_or_date, str)):
        result =  _imm.nextCode_str(
            <str> code_or_date, <bool>main_cycle,
            deref(reference_date._thisptr.get())
        )
    else:
        dt = <Date> code_or_date
        result =  _imm.nextCode_dt(deref(dt._thisptr.get()), <bool>main_cycle)

    return result
