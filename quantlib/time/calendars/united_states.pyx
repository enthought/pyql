cimport quantlib.time._calendar as _calendar
cimport quantlib.time.calendars._united_states as _us
from quantlib.time.calendar cimport Calendar

cdef public enum Market:
    SETTLEMENT     = _us.Settlement # generic settlement calendar
    NYSE           = _us.NYSE # New York stock exchange calendar
    GOVERNMENTBOND = _us.GovernmentBond # government-bond calendar
    NERC           = _us.NERC # off-peak days for NERC

cdef class UnitedStates(Calendar):
    '''United States calendars.

    Public holidays (see: http://www.opm.gov/fedhol/):

     * Saturdays
     * Sundays
     * New Year's Day, January 1st (possibly moved to Monday if actually on 
       Sunday, or to Friday if on Saturday)
     * Martin Luther King's birthday, third Monday in January
     * Presidents' Day (a.k.a. Washington's birthday), third Monday in February
     * Memorial Day, last Monday in May
     * Independence Day, July 4th (moved to Monday if Sunday or Friday if 
       Saturday)
     * Labor Day, first Monday in September
     * Columbus Day, second Monday in October
     * Veterans' Day, November 11th (moved to Monday if Sunday or Friday if 
       Saturday)
     * Thanksgiving Day, fourth Thursday in November
     * Christmas, December 25th (moved to Monday if Sunday or Friday if Saturday)

    Holidays for the stock exchange (data from http://www.nyse.com):

     * Saturdays
     * Sundays
     * New Year's Day, January 1st (possibly moved to Monday if actually on 
       Sunday)
     * Martin Luther King's birthday, third Monday in January (since 1998)
     * Presidents' Day (a.k.a. Washington's birthday), third Monday in February
     * Good Friday
     * Memorial Day, last Monday in May
     * Independence Day, July 4th (moved to Monday if Sunday or Friday if 
       Saturday)
     * Labor Day, first Monday in September
     * Thanksgiving Day, fourth Thursday in November
     * Presidential election day, first Tuesday in November of election years 
       (until 1980)
     * Christmas, December 25th (moved to Monday if Sunday or Friday if 
       Saturday)
     * Special historic closings (see http://www.nyse.com/pdfs/closings.pdf)

    Holidays for the government bond market 
    (data from http://www.bondmarkets.com):

     * Saturdays
     * Sundays
     * New Year's Day, January 1st (possibly moved to Monday if actually on 
       Sunday)
     * Martin Luther King's birthday, third Monday in January
     * Presidents' Day (a.k.a. Washington's birthday), third Monday in February
     * Good Friday
     * Memorial Day, last Monday in May
     * Independence Day, July 4th (moved to Monday if Sunday or Friday if 
       Saturday)
     * Labor Day, first Monday in September
     * Columbus Day, second Monday in October
     * Veterans' Day, November 11th (moved to Monday if Sunday or Friday if 
       Saturday)
     * Thanksgiving Day, fourth Thursday in November
     * Christmas, December 25th (moved to Monday if Sunday or Friday if 
       Saturday)

    Holidays for the North American Energy Reliability Council 
    (data from http://www.nerc.com/~oc/offpeaks.html):

     * Saturdays
     * Sundays
     * New Year's Day, January 1st (possibly moved to Monday if actually on Sunday)
     * Memorial Day, last Monday in May
     * Independence Day, July 4th (moved to Monday if Sunday)
     * Labor Day, first Monday in September
     * Thanksgiving Day, fourth Thursday in November
     * Christmas, December 25th (moved to Monday if Sunday)
    '''

    def __cinit__(self, market=SETTLEMENT):
        self._thisptr = new _us.UnitedStates(<_us.Market>market)
