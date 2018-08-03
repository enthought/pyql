include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport static_pointer_cast
from quantlib._observable cimport Observable as QlObservable
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time._daycounter as _daycounter

cdef class DefaultProbabilityTermStructure(Observable): #not inheriting from TermStructure at this point

    cdef shared_ptr[QlObservable] as_observable(self):
        return static_pointer_cast[QlObservable](self._thisptr)

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
        cdef _date.Date d
        cdef list l = []
        cdef vector[_date.Date] jd = self._thisptr.get().jumpDates()
        for d in jd:
            l.append(date_from_qldate(d))
        return l

    def time_from_reference(self, Date d not None):
        return self._thisptr.get().timeFromReference(deref(d._thisptr))

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
