include '../types.pxi'

from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.time.calendar cimport DateList
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time._daycounter as _daycounter

cdef class DefaultProbabilityTermStructure: #not inheriting from TermStructure at this point


    def survival_probability(self, d, bool extrapolate = False):
        if isinstance(d, Date):
            return self._thisptr.get().survivalProbability(
                deref((<Date>d)._thisptr.get()), extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self._thisptr.get().survivalProbability(<Time>d, extrapolate)
        else:
            raise ValueError('d must be a Date or a float')

    def hazard_rate(self, d, bool extrapolate = False):
        if isinstance(d, Date):
            return self._thisptr.get().hazardRate(
                deref((<Date>d)._thisptr.get()), extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self._thisptr.get().hazardRate(<Time>d, extrapolate)
        else:
            raise ValueError('d must be a Date or a float')

    @property
    def jump_times(self):
        return self._thisptr.get().jumpTimes()

    @property
    def jump_dates(self):
        cdef DateList l = DateList.__new__(DateList)
        l._set_dates(self._thisptr.get().jumpDates())
        return l

    def time_from_reference(self, Date d):
        return self._thisptr.get().timeFromReference(deref(d._thisptr.get()))

    @property
    def max_date(self):
        cdef _date.Date date = self._thisptr.get().maxDate()
        return date_from_qldate(date)

    @property
    def reference_date(self):
        cdef _date.Date date = self._thisptr.get().referenceDate()
        return date_from_qldate(date)

    @property
    def day_counter(self):
        cdef DayCounter dc = DayCounter()
        dc._thisptr = new _daycounter.DayCounter(self._thisptr.get().dayCounter())
        return dc
