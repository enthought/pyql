cimport quantlib.time._calendar as _calendar
cimport quantlib.time.calendars._canada as _ca
from quantlib.time.calendar cimport Calendar

cpdef enum Market:
    SETTLEMENT = _ca.Settlement # generic settlement calendar
    TSX        = _ca.TSX # Toronto stock exchange calendar

cdef class Canada(Calendar):
    ''' Canada calendars.
   '''

    def __cinit__(self, market=SETTLEMENT):
        self._thisptr = new _ca.Canada(<_ca.Market>market)
