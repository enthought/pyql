cimport quantlib.time._calendar as _calendar
cimport quantlib.time.calendars._germany as _gm
from quantlib.time.calendar cimport Calendar

cpdef enum Market:
    Settlement = _gm.Settlement
    FrankfurtStockExchange = _gm.FrankfurtStockExchange # Frankfurt stock-exchange
    Xetra = _gm.Xetra                  # Xetra
    Eurex = _gm.Eurex                  # Eurex
    Euwax = _gm.Euwax                  # Euwax

cdef class Germany(Calendar):
    ''' Germany calendars.
   '''

    def __cinit__(self, Market market=Market.Settlement):

        self._thisptr = _gm.Germany(<_gm.Market>market)
