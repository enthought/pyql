from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.time.date cimport date_from_qldate
from quantlib.time.date cimport Period

cdef class VolatilityTermStructure(TermStructure):

    cdef inline _vts.VolatilityTermStructure* as_vol_ts(self) noexcept nogil:
        return <_vts.VolatilityTermStructure*>self._thisptr.get()

    def option_date_from_tenor(self, Period period not None):
        return date_from_qldate(
            self.as_vol_ts().optionDateFromTenor(deref(period._thisptr)))

    @property
    def extrapolation(self):
        return self.as_vol_ts().allowsExtrapolation()

    @extrapolation.setter
    def extrapolation(self, bool b):
        self.as_vol_ts().enableExtrapolation(b)
