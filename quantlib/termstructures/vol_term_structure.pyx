from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.time.date cimport date_from_qldate
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, Period
cimport quantlib.time._calendar as _calendar

cdef class VolatilityTermStructure:

    cdef inline _vts.VolatilityTermStructure* as_ptr(self) nogil:
        return self._thisptr.get()

    def time_from_reference(self, Date date not None):
        return self.as_ptr().timeFromReference(date._thisptr)

    @property
    def reference_date(self):
        return date_from_qldate(self.as_ptr().referenceDate())

    @property
    def calendar(self):
        cdef Calendar instance = Calendar.__new__(Calendar)
        instance._thisptr = self.as_ptr().calendar()
        return instance

    @property
    def settlement_days(self):
        return self.as_ptr().settlementDays()

    def option_date_from_tenor(self, Period period not None):
        return date_from_qldate(
            self.as_ptr().optionDateFromTenor(deref(period._thisptr)))

    @property
    def extrapolation(self):
        return self.as_ptr().allowsExtrapolation()

    @extrapolation.setter
    def extrapolation(self, bool b):
        self.as_ptr().enableExtrapolation(b)
