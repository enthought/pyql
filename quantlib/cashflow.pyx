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
from quantlib.handle cimport shared_ptr, optional

import_datetime()

cdef class CashFlow:
    """Abstract Base Class.

    Use SimpleCashFlow instead

    """

    @property
    def date(self):
        return date_from_qldate(self._thisptr.get().date())

    @property
    def amount(self):
        return self._thisptr.get().amount()

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
    while it != leg.end():
        _thiscf = deref(it).get()
        itemlist.append((_thiscf.amount(),  _pydate_from_qldate(_thiscf.date())))
        preinc(it)
    return itemlist

cdef class Leg:

    def __init__(self, cashflows: list[CashFlow]):
        '''Takes as input a list of (amount, QL Date) tuples. '''
        cdef CashFlow cf
        for cf in cashflows:
            self._thisptr.push_back(cf._thisptr)

    def items(self):
        '''Return Leg as (amount, date) list. '''

        return leg_items(self._thisptr)

    def __len__(self):
        cdef int size = self._thisptr.size()
        return size

    def __iter__(self):
        cdef CashFlow cf
        cdef vector[shared_ptr[_cf.CashFlow]].iterator it = self._thisptr.begin()
        while it != self._thisptr.end():
            cf = CashFlow.__new__(CashFlow)
            cf._thisptr = deref(it)
            yield cf
            preinc(it)

    def __repr__(self):
        """ Pretty print cash flow schedule. """

        header = "Cash Flow Schedule:\n"
        cdef list values = ["{0!s} {1:f}".format(d, cf) for cf, d in leg_items(self._thisptr)]
        return header + '\n'.join(values)
