from cython.operator cimport dereference as deref, preincrement as preinc
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport optional

cimport _schedule
cimport _date
cimport _calendar
cimport cython
import numpy as np
cimport numpy as np
np.import_array()
from _businessdayconvention cimport Following, BusinessDayConvention

from calendar cimport Calendar
from date cimport date_from_qldate, Date, Period

import warnings

cpdef public enum Rule:
    # Backward from termination date to effective date.
    Backward       = _schedule.Backward
    # Forward from effective date to termination date.
    Forward        = _schedule.Forward
    # No intermediate dates between effective date
    # and termination date.
    Zero           = _schedule.Zero
    # All dates but effective date and termination
    # date are taken to be on the third wednesday
    # of their month (with forward calculation.)
    ThirdWednesday = _schedule.ThirdWednesday
    # All dates but the effective date are taken to be the
    # twentieth of their month (used for CDS schedules in
    # emerging markets.)  The termination date is also modified.
    Twentieth      = _schedule.Twentieth
    # All dates but the effective date are taken to be the
    # twentieth of an IMM month (used for CDS schedules.)  The
    # termination date is also modified.
    TwentiethIMM   = _schedule.TwentiethIMM
    # Same as TwentiethIMM with unrestricted date ends and
    # log/short stub coupon period (old CDS convention).
    OldCDS         = _schedule.OldCDS
    # Credit derivatives standard rule since 'Big Bang' changes
    # in 2009.
    CDS            = _schedule.CDS
    CDS2015        = _schedule.CDS2015

cdef class Schedule:
    """ Payment schedule. """

    def __init__(self, Date effective_date not None, Date termination_date not None,
            Period tenor not None, Calendar calendar not None,
            BusinessDayConvention business_day_convention=Following,
            BusinessDayConvention termination_date_convention=Following,
            int date_generation_rule=Forward, bool end_of_month=False,
            from_classmethod=False
           ):

        if not from_classmethod:
            warnings.warn("Deprecated: use class method from_rule instead",
                DeprecationWarning)

            self._thisptr = new _schedule.Schedule(
                deref(effective_date._thisptr),
                deref(termination_date._thisptr),
                deref(tenor._thisptr.get()),
                deref(calendar._thisptr),
                business_day_convention,
                termination_date_convention,
                <_schedule.Rule>date_generation_rule, end_of_month,
                _date.Date(), _date.Date()
            )
        else:
            pass

    @classmethod
    def from_dates(cls, dates, Calendar calendar not None,
            BusinessDayConvention business_day_convention=Following,
            BusinessDayConvention termination_date_convention=Following,
            Period tenor=None,
            int date_generation_rule=Forward, bool end_of_month=False,
            vector[bool] is_regular=[]):
        # convert lists to vectors
        cdef vector[_date.Date] _dates = vector[_date.Date]()
        for date in dates:
            _dates.push_back(deref((<Date>date)._thisptr))

        cdef Schedule instance = cls.__new__(cls)
        cdef optional[_calendar.Period] opt_tenor
        if tenor is not None:
            opt_tenor = deref(tenor._thisptr)
        instance._thisptr = new _schedule.Schedule(
            _dates,
            deref(calendar._thisptr),
            business_day_convention,
            optional[BusinessDayConvention](
                termination_date_convention),
            opt_tenor,
            optional[_schedule.Rule](<_schedule.Rule>date_generation_rule),
            optional[bool](end_of_month),
            is_regular
        )

        return instance

    @classmethod
    def from_rule(cls, Date effective_date not None,
                  Date termination_date not None,
                  Period tenor not None, Calendar calendar not None,
                  BusinessDayConvention business_day_convention=Following,
                  BusinessDayConvention termination_date_convention=Following,
                  Rule date_generation_rule=Forward, bool end_of_month=False,
                  Date first_date=Date(), Date next_to_lastdate=Date()):

        cdef Schedule instance = cls.__new__(cls)
        instance._thisptr = new _schedule.Schedule(
            deref(effective_date._thisptr),
            deref(termination_date._thisptr),
            deref(tenor._thisptr),
            deref(calendar._thisptr),
            business_day_convention,
            termination_date_convention,
            date_generation_rule, end_of_month,
            deref(first_date._thisptr), deref(next_to_lastdate._thisptr)
            )
        return instance

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL


    def dates(self):
        cdef vector[_date.Date] dates = self._thisptr.dates()
        cdef list t = []
        cdef _date.Date d
        for d in dates:
            t.append(date_from_qldate(d))
        return t

    @cython.boundscheck(False)
    def to_npdates(self):
        cdef np.ndarray[np.int64_t] dates = np.empty(self._thisptr.size(), dtype=np.int64)
        cdef vector[_date.Date].const_iterator it = self._thisptr.begin()
        cdef size_t i = 0
        while it != self._thisptr.end():
            dates[i] = deref(it).serialNumber() - 25569
            i += 1
            preinc(it)
        return dates.view('M8[D]')

    def next_date(self, Date reference_date):
        cdef _date.Date dt = self._thisptr.nextDate(
            deref(reference_date._thisptr)
        )
        return date_from_qldate(dt)

    def previous_date(self, Date reference_date):
        cdef _date.Date dt = self._thisptr.previousDate(
            deref(reference_date._thisptr)
        )
        return date_from_qldate(dt)

    def size(self):
        return self._thisptr.size()

    def at(self, int index):
        cdef _date.Date date = self._thisptr.at(index)
        return date_from_qldate(date)

    def __iter__(self):
        cdef vector[_date.Date].const_iterator it = self._thisptr.begin()
        while it != self._thisptr.end():
            yield date_from_qldate(deref(it))
            preinc(it)

    def __len__(self):
        return self._thisptr.size()

    def __getitem__(self, index):
        cdef size_t i
        if isinstance(index, slice):
            return [date_from_qldate(self._thisptr.at(i))
                    for i in range(*index.indices(len(self)))]
        elif isinstance(index, int):
            return date_from_qldate(self._thisptr.at(index))
        else:
            raise TypeError('index needs to be an integer or a slice')
