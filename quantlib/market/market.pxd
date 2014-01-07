include '../types.pxi'

from libcpp.vector cimport vector
from libcpp.string cimport string

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
    A Market is a virtual environment where financial assets are traded. It defines the
    conventions for quoting prices and yield, for measuring time, etc.
    """

    cdef string _name


cdef class FixedIncomeMarket(Market):
    """
    A Fixed Income Market, defined by:
    - a list of benchmarks instruments (deposits, FRA, swaps, EuroDollar futures, bonds)

    This class models an homogeneous market: It is assumed that the market conventions
    for all fixed rate instruments, including swaps, are all consistent.
    The conventions may vary between the fixed rate instruments and the deposit instruments.
    """

    cdef Calendar _calendar
    cdef Integer  _fixingDays
    cdef BusinessDayConvention _businessDayConvention 
            
    # benchmark fixed rate instrument (bond or swap) parameters

    cdef Frequency _fixedInstrumentFrequency
    cdef BusinessDayConvention _fixedInstrumentConvention
    cdef DayCounter _fixedInstrumentDayCounter

    # benchmark deposit instruments

    cdef DayCounter _depositDayCounter
    # cdef shared_ptr[???] _swFloatingLegIndex

    # the original quotes, as a list of tuples
    cdef _quotes
    # vector of rate helpers, constructed from quotes
    cdef vector[shared_ptr[_rh.RateHelper]]* _rate_helpers
    
    # term structures
    cdef DayCounter _termStructureDayCounter
    cdef Frequency  _fixedRateFrequency

    # term structure, bootstrapped from benchmark instruments
    cdef shared_ptr[_yts.YieldTermStructure]* _yieldTermStructure
    
    # Term structures that will be used for pricing and forecasting
    # forward rates
    cdef shared_ptr[RelinkableHandle[_yts.YieldTermStructure]]* _discountingTermStructure
    cdef shared_ptr[RelinkableHandle[_yts.YieldTermStructure]]* _forecastingTermStructure

        
