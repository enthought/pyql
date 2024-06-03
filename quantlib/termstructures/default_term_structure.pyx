from quantlib.types cimport Time
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.handle cimport static_pointer_cast

cdef class DefaultProbabilityTermStructure(TermStructure):

    cdef inline _dts.DefaultProbabilityTermStructure* as_dts_ptr(self) noexcept nogil:
        return <_dts.DefaultProbabilityTermStructure*>self._thisptr.get()

    def survival_probability(self, d, bool extrapolate = False):
        if isinstance(d, Date):
            return self.as_dts_ptr().survivalProbability(
                (<Date>d)._thisptr, extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self.as_dts_ptr().survivalProbability(<Time>d, extrapolate)
        else:
            raise ValueError('d must be a Date or a float')

    def hazard_rate(self, d, bool extrapolate = False):
        if isinstance(d, Date):
            return self.as_dts_ptr().hazardRate(
                (<Date>d)._thisptr, extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self.as_dts_ptr().hazardRate(<Time>d, extrapolate)
        else:
            raise ValueError('d must be a Date or a float')

    @property
    def jump_times(self):
        return self.as_dts_ptr().jumpTimes()

    @property
    def jump_dates(self):
        cdef _date.Date d
        cdef list l = []
        cdef vector[_date.Date] jd = self.as_dts_ptr().jumpDates()
        for d in jd:
            l.append(date_from_qldate(d))
        return l

cdef class HandleDefaultProbabilityTermStructure:
    def __init__(self, DefaultProbabilityTermStructure ts=None, bool register_as_observer=False):
        if ts is not None:
            self.handle = RelinkableHandle[_dts.DefaultProbabilityTermStructure](
                static_pointer_cast[_dts.DefaultProbabilityTermStructure](ts._thisptr),
                register_as_observer)
