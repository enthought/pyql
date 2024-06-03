from quantlib.handle cimport static_pointer_cast
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as QlDate
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time._daycounter as _dc

cdef class TermStructure(Observable):

    def __init__(self):
        raise NotImplementedError("Abstract Class")

    cdef inline _ts.TermStructure* as_ptr(self) except NULL:
        if not self._thisptr:
            raise ValueError("TermStructure not initialized")
        return <_ts.TermStructure*>self._thisptr.get()

    cdef inline shared_ptr[QlObservable] as_observable(self) noexcept nogil:
        return static_pointer_cast[QlObservable](self._thisptr)

    def time_from_reference(self, Date dt):
        return self.as_ptr().timeFromReference(dt._thisptr)

    @property
    def reference_date(self):
        cdef QlDate ref_date = self.as_ptr().referenceDate()
        return date_from_qldate(ref_date)

    @property
    def max_date(self):
        cdef QlDate max_date = self.as_ptr().maxDate()
        return date_from_qldate(max_date)

    @property
    def max_time(self):
        return self.as_ptr().maxTime()

    @property
    def day_counter(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new _dc.DayCounter(self.as_ptr().dayCounter())
        return dc

    @property
    def settlement_days(self):
        return self.as_ptr().settlementDays()
