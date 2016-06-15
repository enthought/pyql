include '../types.pxi'

from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.time.date cimport Date
from quantlib.time.calendar cimport DateList

cdef class DefaultProbabilityTermStructure: #not inheriting from TermStructure at this point


    def survival_probability(self, d, bool extrapolate = False):
        if isinstance(d, Date):
            return self._thisptr.get().survivalProbability(
                deref((<Date>d)._thisptr), extrapolate)
        elif isinstance(d, float) or isinstance(d, int):
            return self._thisptr.get().survivalProbability(<Time>d, extrapolate)
        else:
            raise ValueError('d must be a Date or a float')

    def hazard_rate(self, d, bool extrapolate = False):
        if isinstance(d, Date):
            return self._thisptr.get().hazardRate(
                deref((<Date>d)._thisptr), extrapolate)
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
