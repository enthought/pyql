from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

cimport _schedule
cimport _date
cimport _calendar
from _businessdayconvention cimport Following

from calendar cimport DateList, Calendar
from date cimport date_from_qldate, Date, Period


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


    def __init__(self, Date effective_date, Date termination_date,
            Period tenor, Calendar calendar,
            int business_day_convention=Following,
            int termination_date_convention=Following,
           int date_generation_rule=Forward, end_of_month=False):

        self._thisptr = new _schedule.Schedule(
            deref(effective_date._thisptr.get()),
            deref(termination_date._thisptr.get()),
            deref(tenor._thisptr.get()),
            deref(calendar._thisptr),
            <_calendar.BusinessDayConvention>business_day_convention,
            <_calendar.BusinessDayConvention>termination_date_convention,
            <_schedule.Rule>date_generation_rule, end_of_month
        )


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
