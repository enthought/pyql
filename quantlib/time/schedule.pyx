from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport optional, make_optional

cimport _schedule
cimport _date
cimport _calendar
from _businessdayconvention cimport Following

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

    def __init__(self, Date effective_date not None, Date termination_date not None,
            Period tenor not None, Calendar calendar not None,
            int business_day_convention=_calendar.Following,
            int termination_date_convention=_calendar.Following,
            int date_generation_rule=Forward, bool end_of_month=False,
            from_classmethod=False
           ):

        if not from_classmethod:
            warnings.warn("Deprecated: use class method from_effective_termination instead",
                DeprecationWarning)

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
            int date_generation_rule=Forward, bool end_of_month=False,
            vector[bool] is_regular=[]):
        # convert lists to vectors
        cdef vector[_date.Date] _dates = vector[_date.Date]()
        for date in dates:
            _dates.push_back(deref((<Date>date)._thisptr.get()))

        cdef Schedule instance = cls.__new__(cls)
        instance._thisptr = new _schedule.Schedule(
            _dates,
            deref(calendar._thisptr),
            <_calendar.BusinessDayConvention>business_day_convention,
            optional[_calendar.BusinessDayConvention](
                <_calendar.BusinessDayConvention>termination_date_convention),
            make_optional[_calendar.Period](tenor is not None, deref(tenor._thisptr.get())),
            optional[_schedule.Rule](<_schedule.Rule>date_generation_rule),
            optional[bool](end_of_month),
            is_regular
        )

        return instance

    @classmethod
    def from_effective_termination(cls, Date effective_date not None, Date termination_date not None,
            Period tenor not None, Calendar calendar not None,
            int business_day_convention=_calendar.Following,
            int termination_date_convention=_calendar.Following,
            int date_generation_rule=Forward, bool end_of_month=False):
        cdef Schedule instance = cls.__new__(cls)
        instance._thisptr = new _schedule.Schedule(
                deref(effective_date._thisptr.get()),
                deref(termination_date._thisptr.get()),
                deref(tenor._thisptr.get()),
                deref(calendar._thisptr),
                <_calendar.BusinessDayConvention>business_day_convention,
                <_calendar.BusinessDayConvention>termination_date_convention,
                <_schedule.Rule>date_generation_rule, end_of_month
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

    def __len__(self):
        return self.size()

    def __getitem__(self, index):
        cdef size_t i
        if isinstance(index, slice):
            return [date_from_qldate(self._thisptr.at(i))
                    for i in range(*index.indices(len(self)))]
        elif isinstance(index, int):
            return date_from_qldate(self._thisptr.at(index))
        else:
            raise TypeError('index needs to be an integer or a slice')
