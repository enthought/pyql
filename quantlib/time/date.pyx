# Cython imports
from cython.operator cimport dereference as deref
from cpython.datetime cimport date_new, date, datetime, import_datetime
from libcpp.string cimport string

# cannot use date.pxd because of name clashing
cimport _date
cimport _period

from _date cimport (
    Date as QlDate, todaysDate, nextWeekday, endOfMonth, isEndOfMonth,
    minDate, maxDate, Year, Month, Day, Hour, Minute, Second, Millisecond,
    Microsecond, isLeap, Size, nthWeekday, serial_type, Integer
)
from _period cimport Period as QlPeriod, parse

# Python imports
import_datetime()
import six

cdef public enum Month:
    January   = _date.January
    February  = _date.February
    March     = _date.March
    April     = _date.April
    May       = _date.May
    June      = _date.June
    July      = _date.July
    August    = _date.August
    September = _date.September
    October   = _date.October
    November  = _date.November
    December  = _date.December
    Jan = _date.Jan
    Feb = _date.Feb
    Mar = _date.Mar
    Apr = _date.Apr
    Jun = _date.Jun
    Jul = _date.Jul
    Aug = _date.Aug
    Sep = _date.Sep
    Oct = _date.Oct
    Nov = _date.Nov
    Dec = _date.Dec

cdef public enum Weekday:
    Sunday   = _date.Sunday
    Monday   = _date.Monday
    Tuesday  = _date.Tuesday
    Wednesday = _date.Wednesday
    Thursday = _date.Thursday
    Friday   = _date.Friday
    Saturday = _date.Saturday
    Sun = _date.Sun
    Mon = _date.Mon
    Tue = _date.Tue
    Wed = _date.Wed
    Thu = _date.Thu
    Fri = _date.Fri
    Sat = _date.Sat

cdef public enum Frequency:
    NoFrequency      = _period.NoFrequency # null frequency
    Once             = _period.Once  # only once, e.g., a zero-coupon
    Annual           = _period.Annual  # once a year
    Semiannual       = _period.Semiannual  # twice a year
    EveryFourthMonth = _period.EveryFourthMonth  # every fourth month
    Quarterly        = _period.Quarterly  # every third month
    Bimonthly        = _period.Bimonthly  # every second month
    Monthly          = _period.Monthly # once a month
    EveryFourthWeek  = _period.EveryFourthWeek # every fourth week
    Biweekly         = _period.Biweekly # every second week
    Weekly           = _period.Weekly # once a week
    Daily            = _period.Daily # once a day
    OtherFrequency   = _period.OtherFrequency # some other unknown frequency

FREQUENCIES = ['NoFrequency', 'Once', 'Annual', 'Semiannual', 'EveryFourthMonth',
               'Quarterly', 'Bimonthly', 'Monthly', 'EveryFourthWeek',
               'Biweekly', 'Weekly', 'Daily', 'OtherFrequency']

_FREQ = ['NoFrequency', 'Once', '1Y', '6M', '4M', '3M', '2M', '1M', '4W', '2W',
        '1W', '1D', 'OtherFrequency']

_FREQ_TO_FREQUENCIES = dict(zip(_FREQ, FREQUENCIES))

_FREQ_DICT = {globals()[name]:name for name in FREQUENCIES}
_STR_FREQ_DICT = {name:globals()[name] for name in FREQUENCIES}

def frequency_to_str(Frequency f):
    """ Converts a PyQL Frequency to a human readable string. """
    return _FREQ_DICT[f]

def code_to_frequency(str name):
    return _STR_FREQ_DICT[_FREQ_TO_FREQUENCIES[name]]

def str_to_frequency(str name):
    """ Converts a string to a PyQL Frequency. """
    return _STR_FREQ_DICT[name]

cdef public enum TimeUnit:
    Days   = _period.Days #: Days = 0
    Weeks  = _period.Weeks #: Weeks = 1
    Months = _period.Months #: Months = 2
    Years  = _period.Years #: Years = 3

cdef class Period:
    ''' Class providing a Period (length + time unit) class and implements a
    limited algebra.

    '''
    def __init__(self, *args):
        if len(args) == 1:
            tenor = args[0]
            if(isinstance(tenor, six.string_types)):
                self._thisptr.reset(new QlPeriod(parse(tenor.encode('utf-8'))))
            else:
                self._thisptr.reset(new QlPeriod(<_period.Frequency>args[0]))
        elif len(args) == 2:
            self._thisptr.reset(new QlPeriod(<Integer> args[0],
                                             <TimeUnit> args[1]))
        elif len(args) == 0:
            self._thisptr.reset(new QlPeriod())
        else:
            raise RuntimeError('Invalid arguments for Period.__init__')

    property length:
        def __get__(self):
            return self._thisptr.get().length()

    property units:
        def __get__(self):
            return self._thisptr.get().units()

    property frequency:
        def __get__(self):
            return self._thisptr.get().frequency()

    def normalize(self):
        '''Normalises the units.'''
        self._thisptr.get().normalize()

    def __sub__(self, value):
        cdef QlPeriod outp
        outp = deref((<Period?>self)._thisptr) - deref((<Period?>value)._thisptr)
        return period_from_qlperiod(outp)

    def __add__(self, value):
        cdef QlPeriod outp
        outp = deref( (<Period?>self)._thisptr) + \
                deref( (<Period?>value)._thisptr)
        return period_from_qlperiod(outp)

    def __mul__(self, value):
        cdef QlPeriod inp
        if isinstance(self, Period):
            inp = deref((<Period>self)._thisptr)
            value = <Integer?> value
        elif isinstance(self, int) and isinstance(value, Period):
            inp = deref((<Period>value)._thisptr)
            value = <Integer> self
        else:
            return NotImplemented

        cdef QlPeriod outp = inp * (<Integer>value)

        return period_from_qlperiod(outp)

    def __iadd__(self, Period value not None):
        if isinstance(self, Period):

            if self.units != value.units:
                raise ValueError('Units must be the same')

            self._thisptr.get().i_add( deref( value._thisptr))

            return self
        else:
            return NotImplemented

    def __isub__(self, Period value not None):
        if isinstance(self, Period):

            if self.units != value.units:
                raise ValueError('Units must be the same')

            self._thisptr.get().i_sub(deref(value._thisptr))

            return self
        else:
            return NotImplemented

    def __idiv__(self, int value):
        if isinstance(self, Period):
            self._thisptr.get().i_div(value)
            return self
        else:
            return NotImplemented

    def __itruediv__(self, int value):
        if isinstance(self, Period):
            self._thisptr.get().i_div(value)
            return self
        else:
            return NotImplemented

    def __richcmp__(self, value, int t):
        cdef QlPeriod p1 = deref((<Period?>self)._thisptr)
        cdef QlPeriod p2 = deref((<Period?>value)._thisptr)

        if t==0:
            return p1 < p2
        elif t==1:
            return p1 <= p2
        elif t==2:
            return p1 == p2
        elif t==3:
            return p1 != p2
        elif t==4:
            return p1 > p2
        elif t==5:
            return p1 >= p2

    def __str__(self):
        cdef _period.stringstream ss
        ss << _period.long_period(deref(self._thisptr))
        return ss.str().decode()

    def __repr__(self):
        cdef _period.stringstream ss
        ss << _period.short_period(deref(self._thisptr))
        return "Period({})".format(ss.str().decode())

    def __float__(self):
        """ Converts the period to a year fraction.

        This will throw an exception if the time unit is not Years or Month."""
        return _period.years(deref(self._thisptr.get()))

cdef Period period_from_qlperiod(const QlPeriod& period):
    cdef Period instance = Period.__new__(Period)
    instance._thisptr.reset(new QlPeriod(period))
    return instance

def years(Period p not None):
    """Converts the period into years as a float.

    This will throw an exception if the time unit is not Years or Months."""
    return _period.years(deref(p._thisptr.get()))

def months(Period p not None):
    """Converts the period intho months as a float.

    This will throw an exception if the time unit is not Years or Months."""
    return _period.months(deref(p._thisptr.get()))

def weeks(Period p not None):
    """Converts the period into weeks as a float.

    This will throw an exception if the time unit is not Days or Weeks."""
    return _period.weeks(deref(p._thisptr.get()))

def days(Period p not None):
    """Converts the period into days as a float.

    This will throw an exception if the time unit is not Days or Weeks."""
    return _period.days(deref(p._thisptr.get()))

cdef class Date:
    """ Date class

    It provides methods to inspect dates as well as methods and
    operators which implement a limited date algebra (increasing and decreasing
    dates, and calculating their difference).

    """

    def __init__(self, *args):
        if len(args) == 3:
            day, month, year = args
            self._thisptr.reset(new QlDate(<Day>day, <Month>month, <Year>year))
        elif len(args) == 6:
            day, month, year, hours, minutes, seconds = args
            self._thisptr.reset(new QlDate(<Day>day, <Month>month, <Year>year,
                <Hour>hours, <Minute>minutes, <Second>seconds, 0, 0))
        elif len(args) == 1:
            serial = args[0]
            self._thisptr.reset(new QlDate(<serial_type> serial))
        elif len(args) == 0:
            self._thisptr.reset(new QlDate())
        else:
            raise RuntimeError('Invalid constructor')

    property month:
        def __get__(self):
            return self._thisptr.get().month()

    property day:
        def __get__(self):
            return self._thisptr.get().dayOfMonth()

    property year:
        def __get__(self):
            return self._thisptr.get().year()

    @property
    def serial(self):
        return self._thisptr.get().serialNumber()

    property weekday:
        def __get__(self):
            return self._thisptr.get().weekday()

    #: Day of the year (one based - Jan 1st = 1)
    property day_of_year:
        def __get__(self):
            return self._thisptr.get().dayOfYear()

    def __str__(self):
        cdef _date.stringstream ss
        ss << _date.iso_datetime(deref(self._thisptr))
        return ss.str().decode()

    def __repr__(self):
        return self.__str__()

    def __hash__(self):
        # Returns a hash based on the serial
        return self.serial


    def __richcmp__(self, date2, int t):
        cdef _date.Date date1 = deref((<Date>self)._thisptr)
        cdef _date.Date c_date2
        if isinstance(date2, (date, datetime)):
            c_date2 = _qldate_from_pydate(date2)
        elif isinstance(date2, Date):
            c_date2 = deref((<Date>date2)._thisptr)
        else:
            return NotImplemented

        if t==0:
            return date1 < c_date2
        elif t==1:
            return date1 <= c_date2
        elif t==2:
            return date1 == c_date2
        elif t==3:
            return date1 != c_date2
        elif t==4:
            return date1 > c_date2
        elif t==5:
            return date1 >= c_date2

        return False

    def __int__(self):
        '''Conversion to int returns the serial value
        '''
        return self._thisptr.get().serialNumber()

    def __add__(self, value):
        cdef QlDate add
        if isinstance(value, Period):
            add = deref((<Date?>self)._thisptr) + deref((<Period>value)._thisptr)
        elif isinstance(value, int):
            add = deref((<Date?>self)._thisptr) + <serial_type>value
        else:
            return NotImplemented
        return date_from_qldate(add)

    def __iadd__(self, value):
        if isinstance(self, Date):
            if isinstance(value, Period):
                self._thisptr.get().i_add(deref((<Period>value)._thisptr))
            elif isinstance(value, int):
                self._thisptr.get().i_add(<serial_type>value)
            return self
        else:
            return NotImplemented

    def __sub__(self, value):
        cdef QlDate sub
        if isinstance(value, Period):
            sub = deref((<Date?>self)._thisptr) - deref((<Period>value)._thisptr)
        elif isinstance(value, int):
            sub = deref((<Date?>self)._thisptr) - <serial_type>value
        elif isinstance(value, Date):
            return deref((<Date?>self)._thisptr) - deref((<Date>value)._thisptr)
        else:
            return NotImplemented
        return date_from_qldate(sub)

    def __isub__(self, value):
        if isinstance(self, Date):
            if isinstance(value, Period):
                self._thisptr.get().i_sub( deref((<Period>value)._thisptr) )
            else:
                self._thisptr.get().i_sub( <serial_type>value)
            return self
        else:
            return NotImplemented

    @classmethod
    def from_datetime(cls, dt):
        """Returns the Quantlib Date object from the date/datetime object. """
        cdef Date instance = Date.__new__(Date)
        if not isinstance(dt, date):
            raise TypeError
        instance._thisptr.reset(new QlDate(_qldate_from_pydate(dt)))
        return instance

def today():
    '''Today's date. '''
    cdef QlDate today = todaysDate()
    return date_from_qldate(today)

def next_weekday(Date date, int weekday):
    ''' Returns the next given weekday following or equal to the given date
    '''
    cdef QlDate nwd = nextWeekday( deref(date._thisptr), <_date.Weekday>weekday)
    return date_from_qldate(nwd)

def nth_weekday(int size, int weekday, int month, int year):
    '''Return the n-th given weekday in the given month and year

    E.g., the 4th Thursday of March, 1998 was March 26th, 1998.

    see http://www.cpearson.com/excel/DateTimeWS.htm
    '''
    cdef QlDate nwd = nthWeekday(<Size>size, <_date.Weekday>weekday, <_date.Month>month, <Year>year)
    return date_from_qldate(nwd)

def end_of_month(Date date not None):
    '''Last day of the month to which the given date belongs.'''
    cdef QlDate eom = endOfMonth(deref(date._thisptr))
    return date_from_qldate(eom)

def maxdate():
    '''Latest allowed date.'''
    cdef QlDate mdate = maxDate()
    return date_from_qldate(mdate)

def mindate():
    '''Earliest date allowed.'''
    cdef QlDate mdate = minDate()
    return date_from_qldate(mdate)

def is_end_of_month(Date date not None):
    '''Whether a date is the last day of its month.'''
    return isEndOfMonth(deref(date._thisptr.get()))

def is_leap(int year):
    '''Whether the given year is a leap one.'''
    return isLeap(<Year> year)

cdef Date date_from_qldate(const QlDate& date):
    '''Converts a QuantLib::Date (QlDate) to a cython Date instance.'''
    cdef Date instance = Date.__new__(Date)
    instance._thisptr.reset(new QlDate(date))
    return instance

# Date Interfaces

cdef object _pydate_from_qldate(QlDate qdate):
    """ Converts a QuantLib Date (C++) to a datetime.date object. """

    cdef int m = qdate.month()
    cdef int d = qdate.dayOfMonth()
    cdef int y = qdate.year()

    return date_new(y, m, d)

cpdef object pydate_from_qldate(Date qdate):
    """ Converts a PyQL Date to a datetime.date object. """
    cdef QlDate* d = qdate._thisptr.get()
    return date_new(d.year(), d.month(), d.dayOfMonth())

cdef QlDate _qldate_from_pydate(object pydate):
    """ Converts a datetime.date to a QuantLib (C++) object. """
    if isinstance(pydate, datetime):
        return QlDate(<Day>pydate.day, <Month>pydate.month, <Year>pydate.year,
                      <Hour>pydate.hour, <Minute>pydate.hour, <Second>pydate.second,
                      0, <Microsecond>pydate.microsecond)
    elif isinstance(pydate, date):
        return QlDate(<Day>pydate.day, <Month>pydate.month, <Year>pydate.year)

cpdef Date qldate_from_pydate(object pydate):
    """ Converts a datetime.date to a PyQL date. """
    return Date.from_datetime(pydate)
