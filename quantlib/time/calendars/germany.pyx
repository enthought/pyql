cimport quantlib.time._calendar as _calendar
cimport quantlib.time.calendars._germany as _gm
from quantlib.time.calendar cimport Calendar

SETTLEMENT = 0
FrankfurtStockExchange = 1 # Frankfurt stock-exchange
XETRA = 2                  # Xetra
EUREX = 3                  # Eurex
EUWAX = 4                  # Euwax

cdef class Germany(Calendar):
    ''' Germany calendars.
   '''

    def __cinit__(self, market=SETTLEMENT):

        self._thisptr = <_calendar.Calendar*> new \
            _gm.Germany(<_gm.Market>market)


