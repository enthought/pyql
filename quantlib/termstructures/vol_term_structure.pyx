from cython.operator cimport dereference as deref
from quantlib.time.date cimport date_from_qldate
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, Period
cimport quantlib.time._calendar as _calendar

cdef class VolatilityTermStructure:

    def time_from_reference(self, Date date not None):
        return self._thisptr.get().timeFromReference(deref(date._thisptr))

    @property
    def reference_date(self):
        return date_from_qldate(self._thisptr.get().referenceDate())

    @property
    def calendar(self):
        cdef Calendar instance = Calendar.__new__(Calendar)
        instance._thisptr = new _calendar.Calendar(self._thisptr.get().calendar())
        return instance

    @property
    def settlement_days(self):
        return self._thisptr.get().settlementDays()

    def option_date_from_tenor(self, Period period not None):
        return date_from_qldate(
            self._thisptr.get().optionDateFromTenor(deref(period._thisptr)))
