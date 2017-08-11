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
    return _imm.isIMMdate(deref(dt._thisptr), main_cycle)

def is_IMM_code(str imm_code, bool main_cycle=True):
    # returns whether or not the given string is an IMM code
    cdef string _code = imm_code.encode('utf-8')
    return _imm.isIMMcode(_code, main_cycle)

def code(Date imm_date):
    cdef string _code = _imm.code(deref(imm_date._thisptr))
    return _code.decode("utf-8")

def date(str imm_code, Date reference_date=Date()):
    cdef string _code = imm_code.encode('utf-8')
    cdef _date.Date tmp = _imm.date(_code, deref(reference_date._thisptr))
    return date_from_qldate(tmp)

def next_date(code_or_date, main_cycle=True, Date reference_date=Date()):
    """ Next IMM date following the given date

    returns the 1st delivery date for next contract listed in the
    International Money Market section of the Chicago Mercantile
    Exchange.
    """

    cdef _date.Date result

    cdef Date dt

    if isinstance(code_or_date, Date):
        dt = <Date> code_or_date
        result =  _imm.nextDate_dt(deref(dt._thisptr), <bool>main_cycle)
    else:
        result =  _imm.nextDate_str(code_or_date.encode('utf-8'),
            <bool>main_cycle, deref(reference_date._thisptr.get()))

    return date_from_qldate(result)

def next_code(code_or_date, main_cycle=True, Date reference_date=Date()):
    """ Next IMM code following the given date or code

    Returns the IMM code for next contract listed in the
    International Money Market section of the Chicago Mercantile Exchange.
    """

    cdef Date dt
    cdef string result

    if isinstance(code_or_date, Date):
        dt = <Date> code_or_date
        result =  _imm.nextCode_dt(deref(dt._thisptr), <bool>main_cycle)
    else:
        result =  _imm.nextCode_str(code_or_date.encode('utf-8'),
                                    <bool>main_cycle,
                                    deref(reference_date._thisptr.get()))

    return result.decode("utf-8")
