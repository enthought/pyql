from cython.operator cimport dereference as deref, preincrement as preinc

cimport _time_series as _ts
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as QlDate
from libcpp.utility cimport pair
from libcpp.map cimport map

cdef class TimeSeries:
    @property
    def first_date(self):
        return date_from_qldate(self._thisptr.firstDate())

    @property
    def last_date(self):
        return date_from_qldate(self._thisptr.lastDate())

    def __iter__(self):

        cdef map[QlDate, double].const_iterator it = self._thisptr.const_begin()
        while it != self._thisptr.const_end():
            yield (date_from_qldate(deref(it).first), deref(it).second)
            preinc(it)

    def __len__(self):
        return self._thisptr.size()

    def __bool__(self):
        return not self._thisptr.empty()

    def __getitem__(self, Date date not None):
        return self._thisptr[deref(date._thisptr)]

    def __setitem__(self, Date date, value):
        self._thisptr[deref(date._thisptr)] = value
