cimport quantlib.time.calendars._germany as _gm
from quantlib.time.calendar cimport Calendar

cdef class Germany(Calendar):
    ''' Germany calendars.
   '''
    Settlement = Market.Settlement
    FrankfurtStockExchange = Market.FrankfurtStockExchange
    Xetra = Market.Xetra
    Eurex = Market.Eurex
    Euwax = Market.Euwax

    def __cinit__(self, Market market=Market.Settlement):

        self._thisptr = _gm.Germany(market)
