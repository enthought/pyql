from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from _schedule cimport optional

cimport _schedule
cimport _date
cimport _calendar

from calendar cimport DateList, Calendar
from date cimport date_from_qldate, Date, Period

import warnings

cdef public enum Rule:
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

cdef class Schedule:
    """ Payment schedule. """

    def __init__(self, Date effective_date=None, Date termination_date=None,
            Period tenor=None, Calendar calendar=None,
            int business_day_convention=_calendar.Following,
            int termination_date_convention=_calendar.Following,
            int date_generation_rule=Forward, end_of_month=False,
            from_classmethod=False
           ):

        if not from_classmethod:
            warnings.warn("Deprecated: use class methods from_effective_termination instead",
                DeprecationWarning)

            if not (effective_date and termination_date and tenor and calendar):
                raise ValueError(
                    "Must specify effective_date, termination_date, tenor, and calendar")
            self._thisptr = new _schedule.Schedule(
                deref(effective_date._thisptr.get()),
                deref(termination_date._thisptr.get()),
                deref(tenor._thisptr.get()),
                deref(calendar._thisptr),
                <_calendar.BusinessDayConvention>business_day_convention,
                <_calendar.BusinessDayConvention>termination_date_convention,
                <_schedule.Rule>date_generation_rule, <bool>end_of_month
            )
        else:
            pass

    @classmethod
    def from_dates(cls, dates, Calendar calendar, int business_day_convention=_calendar.Following,
            int termination_date_convention=_calendar.Following, Period tenor=None,
            int date_generation_rule=Forward, end_of_month=False, is_regular=[]):
        # convert lists to vectors
        cdef vector[_date.Date] _dates = vector[_date.Date]()
        for date in dates:
            _dates.push_back(deref((<Date>date)._thisptr.get()))

        cdef vector[bool] _is_regular = vector[bool]()
        for regular in is_regular:
            _is_regular.push_back(regular)

        cdef Schedule instance = cls(from_classmethod=True)
        instance._thisptr = new _schedule.Schedule(
            _dates,
            deref(calendar._thisptr),
            <_calendar.BusinessDayConvention>business_day_convention,
            optional[_calendar.BusinessDayConvention](
                <_calendar.BusinessDayConvention>termination_date_convention),
            (optional[_calendar.Period](deref(tenor._thisptr.get())) if tenor
                else <optional[_calendar.Period]>_schedule.none),
            optional[_schedule.Rule](<_schedule.Rule>date_generation_rule),
            optional[bool](<bool>end_of_month),
            _is_regular
        )

        return instance

    @classmethod
    def from_effective_termination(cls, Date effective_date, Date termination_date,
            Period tenor, Calendar calendar,
            int business_day_convention=_calendar.Following,
            int termination_date_convention=_calendar.Following,
            int date_generation_rule=Forward, end_of_month=False):
        cdef Schedule instance = cls(from_classmethod=True)
        instance._thisptr = new _schedule.Schedule(
                deref(effective_date._thisptr.get()),
                deref(termination_date._thisptr.get()),
                deref(tenor._thisptr.get()),
                deref(calendar._thisptr),
                <_calendar.BusinessDayConvention>business_day_convention,
                <_calendar.BusinessDayConvention>termination_date_convention,
                <_schedule.Rule>date_generation_rule, <bool>end_of_month
            )
        return instance

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL


    def dates(self):
        cdef vector[_date.Date] dates = self._thisptr.dates()
        t = DateList()
        t._set_dates(dates)
        return t

    def next_date(self, Date reference_date):
        cdef _date.Date dt = self._thisptr.nextDate(
            deref(reference_date._thisptr.get())
        )
        return date_from_qldate(dt)

    def previous_date(self, Date reference_date):
        cdef _date.Date dt = self._thisptr.previousDate(
            deref(reference_date._thisptr.get())
        )
        return date_from_qldate(dt)

    def size(self):
        return self._thisptr.size()

    def at(self, int index):
        cdef _date.Date date = self._thisptr.at(index)
        return date_from_qldate(date)

    def __iter__(self):
        return (d for d in self.dates())
