# Copyright (C) 2013, Enthought Inc
# Copyright (C) 2013, Patrick Henaff
# Copyright (c) 2012 BG Research LLC
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

cimport _cashflow as _cf
cimport quantlib.time._date as _date
cimport quantlib.time.date as date

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref, preincrement as preinc
from quantlib.handle cimport shared_ptr
import datetime

cdef class CashFlow:
    """Abstract Base Class.

    Use SimpleCashFlow instead

    """
    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self):
        raise ValueError(
            'This is an abstract class.'
        )

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    property date:
        def __get__(self):
            cdef _date.Date cf_date
            if self._thisptr:
                cf_date = self._thisptr.get().date()
                return date.date_from_qldate(cf_date)
            else:
                return None

    property amount:
        def __get__(self):
            if self._thisptr:
                return self._thisptr.get().amount()
            else:
                return None


cdef class SimpleCashFlow(CashFlow):

    def __init__(self, Real amount, date.Date cfdate):
        cdef _date.Date* _cfdate = cfdate._thisptr.get()

        self._thisptr = new shared_ptr[_cf.CashFlow](
            new _cf.SimpleCashFlow(amount, deref(_cfdate))
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
        itemlist.append((_thiscf.amount(),  date._pydate_from_qldate(_thiscf.date())))
        preinc(it)
    return itemlist

cdef class SimpleLeg:

    def __init__(self, leg=None):
        '''Takes as input a list of (amount, QL Date) tuples. '''

        cdef shared_ptr[_cf.CashFlow] _thiscf
        cdef _date.Date _thisdate

        for amount, d in leg:
            if isinstance(d, date.Date):
               _thisdate = deref((<date.Date>d)._thisptr.get())
            elif isinstance(d, datetime.date):
               _thisdate = date._qldate_from_pydate(d)
            else:
               raise TypeError("second element needs to be a QuantLib Date or datetime.date")

            _thiscf = shared_ptr[_cf.CashFlow](
                new _cf.SimpleCashFlow(amount, _thisdate)
            )

            self._thisptr.push_back(_thiscf)

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
            yield (_thiscf.amount(), date._pydate_from_qldate(_thiscf.date()))
            preinc(it)

    def __repr__(self):
        """ Pretty print cash flow schedule. """

        header = "Cash Flow Schedule:\n"
        values = ("{0!s} {1:f}".format(d, cf) for cf, d in self)
        return header + '\n'.join(values)
