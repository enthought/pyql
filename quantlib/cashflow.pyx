# Copyright (C) 2013, Enthought Inc
# Copyright (C) 2013, Patrick Henaff
# Copyright (c) 2012 BG Research LLC
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
from quantlib.types cimport Real
cimport quantlib._cashflow as _cf
cimport quantlib.time._date as _date

from quantlib.time.date cimport (
    Date, _qldate_from_pydate, _pydate_from_qldate, date_from_qldate)
from libcpp.vector cimport vector
from libcpp cimport bool
from cpython.datetime cimport date, import_datetime
from cython.operator cimport dereference as deref, preincrement as preinc
from quantlib.handle cimport shared_ptr, static_pointer_cast, optional

import_datetime()

cdef class CashFlow:
    """Abstract Base Class.

    Use SimpleCashFlow instead

    """

    def __cinit__(self):
        if __class__ == CashFlow:
            raise ValueError(
                'This is an abstract class.'
            )

    property date:
        def __get__(self):
            cdef:
                _date.Date cf_date
                _cf.CashFlow* cf = self._thisptr.get()
            if cf:
                cf_date = cf.date()
                return date_from_qldate(cf_date)
            else:
                return None

    property amount:
        def __get__(self):
            cdef _cf.CashFlow* cf = self._thisptr.get()
            if cf:
                return cf.amount()
            else:
                return None

    def has_occured(self, Date ref_date, include_ref_date=None):
        cdef _cf.CashFlow* cf = self._thisptr.get()
        cdef optional[bool] c_include_ref_date
        if include_ref_date is not None:
            c_include_ref_date = <bool>include_ref_date
        if cf:
            return cf.hasOccurred(deref(ref_date._thisptr), c_include_ref_date)

cdef class SimpleCashFlow(CashFlow):

    def __init__(self, Real amount, Date cfdate):
        self._thisptr = shared_ptr[_cf.CashFlow](
            new _cf.SimpleCashFlow(amount, deref(cfdate._thisptr))
        )

    def __str__(self):
        return 'Simple Cash Flow: {:f}, {!s}'.format(
            self.amount, self.date
        )

cdef list leg_items(const _cf.Leg& leg):
    """
    Returns a list of (amount, pydate)
    """
    cdef list itemlist = []
    cdef vector[shared_ptr[_cf.CashFlow]].const_iterator it = leg.const_begin()
    cdef _cf.CashFlow* _thiscf
    while it != leg.end():
        _thiscf = deref(it).get()
        itemlist.append((_thiscf.amount(),  _pydate_from_qldate(_thiscf.date())))
        preinc(it)
    return itemlist

cdef class Leg:

    def __init__(self, leg=[]):
        '''Takes as input a list of (amount, QL Date) tuples. '''

        cdef _date.Date _thisdate

        for amount, d in leg:
            if isinstance(d, Date):
               _thisdate = deref((<Date>d)._thisptr)
            elif isinstance(d, date):
               _thisdate = _qldate_from_pydate(d)
            else:
               raise TypeError("second element needs to be a QuantLib Date or datetime.date")

            self._thisptr.emplace_back(new _cf.SimpleCashFlow(amount, _thisdate))

    def items(self):
        '''Return Leg as (amount, date) list. '''

        return leg_items(self._thisptr)

    def __len__(self):
        cdef int size = self._thisptr.size()
        return size

    def __iter__(self):
        cdef vector[shared_ptr[_cf.CashFlow]].iterator it = self._thisptr.begin()
        cdef _cf.CashFlow* _thiscf
        while it != self._thisptr.end():
            _thiscf = deref(it).get()
            yield (_thiscf.amount(), _pydate_from_qldate(_thiscf.date()))
            preinc(it)

    def __repr__(self):
        """ Pretty print cash flow schedule. """

        header = "Cash Flow Schedule:\n"
        values = ("{0!s} {1:f}".format(d, cf) for cf, d in self)
        return header + '\n'.join(values)
