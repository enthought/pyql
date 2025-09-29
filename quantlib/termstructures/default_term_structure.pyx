from quantlib.types cimport Time
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.time.date cimport Date, date_from_qldate
cimport quantlib.time._date as _date
from quantlib.ext cimport static_pointer_cast

cdef class DefaultProbabilityTermStructure(TermStructure):

    cdef inline _dts.DefaultProbabilityTermStructure* as_dts_ptr(self) noexcept nogil:
        return <_dts.DefaultProbabilityTermStructure*>self._thisptr.get()

    def survival_probability(self, d, bool extrapolate = False):
        """Survival probability

        This returns the survival probability from the reference
        date until a given date or time.  In the former case, the time
        is calculated as a fraction of year from the reference date.

        Parameters
        ----------
        d : :class:`~quantlib.time.date.Date` or float
        extrapolate : bool

        """

        if isinstance(d, Date):
            return self.as_dts_ptr().survivalProbability(
                (<Date>d)._thisptr, extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self.as_dts_ptr().survivalProbability(<Time>d, extrapolate)
        else:
            raise TypeError('d must be a Date or a float')

    def hazard_rate(self, d, bool extrapolate = False):
        """Hazard rate

        This returns the hazard rate at a given date or time.
        In the former case, the time is calculated as a fraction of
        year from the reference date.

        Hazard rates are defined with annual frequency and continuous compounding.

        Parameters
        ----------
        d : :class:`~quantlib.time.date.Date` or float
        extrapolate : bool

        """
        if isinstance(d, Date):
            return self.as_dts_ptr().hazardRate(
                (<Date>d)._thisptr, extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self.as_dts_ptr().hazardRate(<Time>d, extrapolate)
        else:
            raise TypeError('d must be a Date or a float')

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
