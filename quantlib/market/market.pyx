from libcpp.vector cimport vector
from libcpp.string cimport string
from cpython.string cimport PyString_AsString

cimport quantlib.termstructures.yields._rate_helpers as _rh
cimport quantlib.termstructures._yield_term_structure as _yts

from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle

from quantlib.termstructures.yields.rate_helpers cimport RateHelper
from quantlib.time.daycounter cimport DayCounter
from quantlib.quotes cimport Quote
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period, Date

from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._period cimport Frequency, Days


cdef class Market:
    """
    Abstract Market class.
    A Market is a virtual environment where financial assets are traded.
    It defines the conventions for quoting prices and yield,
    for measuring time, etc.
    """

    def __init__(self, str name):
        self._name = string(PyString_AsString(name))

    property name:
        def __get__(self):
            return(self._name)

cdef class FixedIncomeMarket(Market):
    """
    A Fixed Income Market, defined by:
    - a list of benchmarks instruments (deposits, FRA, swaps,
      EuroDollar futures, bonds)
    - a set of market conventions, needed to interpreted the quoted
      prices of benchmark instruments, and for computing
      derived quantities (yield curves)
      
    This class models an homogeneous market: It is assumed that the
    market conventions for all fixed rate instruments, including swaps,
    are all consistent. The conventions may vary between the fixed rate
    instruments and the deposit instruments.
    """

    ## def __init__(self, quotes,
    ##              str floating_rate_index,
    ##              Integer fixingDays = 2,
    ##              Frequency fixedRateFrequency = Annual,
    ##              BusinessDayConvention fixedInstrumentConvention=Unadjusted, 
    ##              DayCounter fixedInstrumentDayCounter =
    ##              Thirty360(), 
    ##              DayCounter termStructureDayCounter =
    ##              ActualActual()
    ##              ):
    ##     self._fixingDays = fixingDays
    ##     self._fixedRateFrequency = fixedRateFrequency
    ##     self._fixedInstrumentFrequency = fixedRateFrequency
    ##     self._fixedInstrumentConvention = fixedInstrumentConvention
    ##     self._fixedInstrumentDayCounter = fixedInstrumentDayCounter
    ##     self._termStructureDayCounter = termStructureDayCounter

    ##     # floating rate index
    ##     self._swFloatingLegIndex = swFloatingLegIndex
    ##     self._businessDayConvention = _fixedInstrumentConvention
        
    ##     # convert quotes to std::vector of rate_helpers
    ##     for quote in quotes:
    ##         # construct rate helper
    ##         helper = ?
    ##         _rate_helpers.push_back(
    ##             deref((<RateHelper>helper)._thisptr))
    
    ## def __str__(self):
    ##     return 'Fixed Income Market: %s' % self._name

    ## def update(FixedIncomeMarket a_market) {
    ##     self._calendar = a_market._calendar
    ##     self._fixingDays = a_market._fixingDays
    ##     self._depositDayCounter = a_market._depositDayCounter
    ##     self._businessDayConvention = a_market._businessDayConvention
    ##     self._fixedInstrumentFrequency = \
    ##     a_market._fixedInstrumentFrequency
    ##     self._fixedInstrumentConvention = \
    ##     a_market._fixedInstrumentConvention
    ##     self._fixedInstrumentDayCounter = \
    ##     a_market._fixedInstrumentDayCounter
    ##     self._swFloatingLegIndex = a_market._swFloatingLegIndex
    ##     self._termStructureDayCounter = \
    ##     a_market._termStructureDayCounter
    ##     self._fixedRateFrequency = a_market._fixedRateFrequency
            
    ##     # For a swap curve, the you need to use the floating index
    ##     # calendar to avoid segmentation faults on bad dates.
    ##     # TODO:  this should be fixed in QuantLib's IborIndex Class
    ##     self._calendar = _swFloatingLegIndex.fixingCalendar()
    ##     self._businessDayConvention = _swFloatingLegIndex.businessDayConvention()
    ##     self._depositDayCounter = _swFloatingLegIndex.dayCounter()

    ## property calendar:
    ##     def __get__(self):
    ##         return self._calendar
        
    ## property fixing_days:
    ##     def __get__(self):
    ##         return self._fixingDays

    ## property deposit_day_counter:
    ##     def __get__(self):
    ##         return self._depositDayCounter

    ## property fixed_rate_frequency:
    ##     def __get__(self):
    ##         return _fixedInstrumentFrequency

    ## property fixed_rate_convention:
    ##     def __get__(self):
    ##         return self._fixedInstrumentConvention

    ## property fixed_rate_day_counter:
    ##     def __get__(self):
    ##         return self._fixedInstrumentDayCounter

    ## property ts_day_counter:
    ##     def __get__(self):
    ##         return self._termStructureDayCounter

    ## property reference_date:
    ##     def __get__(self):
    ##         return self.discountingTermStructure().currentLink()->referenceDate()

    ## property max_date:
    ##     def __get__(self):
    ##         return self.discountingTermStructure().currentLink()->maxDate()


    ## def bootstrap_term_structure(self):
    ##     return 0
    
    ## def discount(self, double maturity, bool extrapolate=True):
    ##     return 0

    ## def discount(Date maturity_date, bool extrapolate=false):
    ##     return 0

