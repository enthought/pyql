from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.time.date cimport date_from_qldate
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, Period
cimport quantlib.time._calendar as _calendar

cdef class VolatilityTermStructure:

    cdef inline _vts.VolatilityTermStructure* as_ptr(self) nogil:
        return self._thisptr.get()

    @staticmethod
    cdef Handle[_vts.VolatilityTermStructure] handle(vol):
        if isinstance(vol, VolatilityTermStructure):
            return Handle[_vts.VolatilityTermStructure]((<VolatilityTermStructure>vol)._thisptr, False)
        elif isinstance(vol, HandleVolatilityTermStructure):
            return (<HandleVolatilityTermStructure>vol).handle
        else:
            raise TypeError("vol needs to be either a SwaptionVolatilityStructure or a HandleSwaptionVolatilityStructure")

    def time_from_reference(self, Date date not None):
        return self.as_ptr().timeFromReference(deref(date._thisptr))

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

cdef class HandleVolatilityTermStructure:
    def __init__(self, VolatilityTermStructure structure not None, cbool register_as_observer):
        self.handle = RelinkableHandle[_vts.VolatilityTermStructure](structure._thisptr, register_as_observer)

    def link_to(self, VolatilityTermStructure structure not None, cbool register_as_observer=True):
        self.handle.linkTo(structure._thisptr, register_as_observer)
