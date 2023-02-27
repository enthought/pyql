cimport quantlib.time.calendars._canada as _ca
from quantlib.time.calendar cimport Calendar

cdef class Canada(Calendar):
    ''' Canada calendars.
   '''

    def __cinit__(self, Market market=Market.Settlement):
        self._thisptr = new _ca.Canada(market)
