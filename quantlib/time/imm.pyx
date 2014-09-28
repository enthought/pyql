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
from quantlib.util.compat cimport (
    utf8_char_array_to_py_compat_str, py_compat_str_as_utf8_string
)


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

def is_IMM_code(str imm_code, bool main_cycle=True):
    # returns whether or not the given string is an IMM code
    cdef string _code = py_compat_str_as_utf8_string(imm_code)
    return _imm.isIMMcode(_code, main_cycle)

def code(Date imm_date):
    cdef string _code = _imm.code(deref(imm_date._thisptr.get()))
    return utf8_char_array_to_py_compat_str(_code.c_str())

def date(str imm_code, Date reference_date=Date()):
    cdef string _code = py_compat_str_as_utf8_string(imm_code)
    cdef _date.Date tmp = _imm.date(_code, deref(reference_date._thisptr.get()))
    return date_from_qldate(tmp)

def next_date(*args):
    """
    next IMM date following the given date
    returns the 1st delivery date for next contract listed in the
    International Money Market section of the Chicago Mercantile
    Exchange.
    """

    cdef _date.Date tmp
    
    cdef Date reference_date    
    cdef Date dt
    cdef string _code

    if len(args) < 2:
        main_cycle = True
    else:
        main_cycle = args[1]

    if(isinstance(args[0], str)):
        _code = py_compat_str_as_utf8_string(args[0])
        if len(args) == 3:
            reference_date = <Date> args[2]
        else:
            reference_date = Date()
        tmp =  _imm.nextDate_str(_code, <bool>main_cycle, deref(reference_date._thisptr.get()))
    else:
        dt = <Date> args[0]
        tmp =  _imm.nextDate_dt(deref(dt._thisptr.get()), <bool>main_cycle)

    return date_from_qldate(tmp)
    
def next_code(*args):
    """
    //! next IMM code following the given date
    /*! returns the IMM code for next contract listed in the
        International Money Market section of the Chicago Mercantile
        Exchange.
    """

    cdef Date reference_date    
    cdef Date dt
    cdef string _code
    cdef string tmp

    if len(args) < 2:
        main_cycle = True
    else:
        main_cycle = args[1]

    if isinstance(args[0], str):
        _code = py_compat_str_as_utf8_string(args[0])
        if len(args) == 3:
            reference_date = <Date> args[2]
        else:
            reference_date = Date()
        tmp =  _imm.nextCode_str(_code, <bool>main_cycle, deref(reference_date._thisptr.get()))
    elif isinstance(args[0], Date):
        dt = <Date> args[0]
        tmp =  _imm.nextCode_dt(deref(dt._thisptr.get()), <bool>main_cycle)
    else:
        raise ValueError('Wrong type of input')

    py_str = utf8_char_array_to_py_compat_str(tmp.c_str())
    return py_str