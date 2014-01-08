import datetime

from cython.operator cimport dereference as deref

# cannot use date.pxd because of name clashing
cimport _date
cimport _period

from _date cimport (
    Date as QlDate, Date_todaysDate, Date_nextWeekday,
    Date_endOfMonth, Date_isEndOfMonth, Date_minDate, Date_maxDate, Year,
    Date_isLeap, Size, Date_nthWeekday, BigInteger, Integer
)
from _period cimport (
    Period as QlPeriod, mult_op, sub_op, eq_op, neq_op,
    g_op, geq_op, l_op, leq_op
    )

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
_FREQ_DICT = {globals()[name]:name for name in FREQUENCIES}
_STR_FREQ_DICT = {name:globals()[name] for name in FREQUENCIES}

def frequency_to_str(Frequency f):
    """ Converts a PyQL Frequency to a human readable string. """
    return _FREQ_DICT[f]

def str_to_frequency(char* name):
    """ Converts a string to a PyQL Frequency. """
    return _STR_FREQ_DICT[name]

cdef public enum TimeUnit:
    Days   = _period.Days
    Weeks  = _period.Weeks
    Months = _period.Months
    Years  = _period.Years

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

cdef class Period:
    ''' Class providing a Period (length + time unit) class and implements a
    limited algebra.

    '''

    def __cinit__(self, *args):
        if len(args) == 1:
            self._thisptr = new shared_ptr[QlPeriod](
                new QlPeriod(<_period.Frequency>args[0]))
        elif len(args) == 2:
            self._thisptr = new shared_ptr[QlPeriod](
                new QlPeriod(<Integer> args[0], <_period.TimeUnit> args[1]))
        elif len(args) == 0:
            self._thisptr = new shared_ptr[QlPeriod]()
        else:
            raise RuntimeError('Invalid arguments for Period.__cinit__')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

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
        if isinstance(self, Period) and isinstance(value, Period):
            outp = sub_op(deref( (<Period>self)._thisptr.get()),
                    deref( (<Period>value)._thisptr.get()))

        # fixme : this is inefficient and ugly ;-)
        return Period(outp.length(), outp.units())

    def __mul__(self, value):
        cdef QlPeriod inp
        if isinstance(self, Period):
            inp = deref((<Period>self)._thisptr.get())
            value = <int> value
        elif isinstance(self, int) and isinstance(value, Period):
            inp = deref((<Period>value)._thisptr.get())
            value = self
        else:
            raise NotImplemented()

        cdef QlPeriod outp = mult_op(inp, value)

        # fixme : this is inefficient and ugly ;-)
        return Period(outp.length(), outp.units())

    def __iadd__(self, value):
        cdef QlPeriod p1
        cdef QlPeriod* tmp  = (<Period>value)._thisptr.get()

        if isinstance(self, Period) and isinstance(value, Period):

            if self.units != value.units:
                raise ValueError('Units must be the same')

            p1 = self._thisptr.get().i_add( deref( tmp ))

            return self
        else:
            return NotImplemented

    def __isub__(self, value):
        cdef QlPeriod p1
        cdef QlPeriod* tmp  = (<Period>value)._thisptr.get()

        if isinstance(self, Period) and isinstance(value, Period):

            if self.units != value.units:
                raise ValueError('Units must be the same')

            p1 = self._thisptr.get().i_sub( deref( tmp ))

            return self
        else:
            return NotImplemented

    def __idiv__(self, value):
        cdef QlPeriod p1

        if isinstance(self, Period) and isinstance(value, int):

            p1 = self._thisptr.get().i_div( <int> value)

            return self
        else:
            return NotImplemented


    def __richcmp__(self, value, t):

        cdef QlPeriod* p1 = (<Period>self)._thisptr.get()
        if not isinstance(value, Period):
            return False

        cdef QlPeriod* p2 = (<Period>value)._thisptr.get()

        if t==0:
            return l_op( deref(p1), deref(p2))
        elif t==1:
            return leq_op( deref(p1), deref(p2))
        elif t==2:
            return eq_op( deref(p1), deref(p2))
        elif t==3:
            return neq_op( deref(p1), deref(p2))
        elif t==4:
            return g_op( deref(p1), deref(p2))
        elif t==5:
            return geq_op( deref(p1), deref(p2))

    def __str__(self):
        return 'Period %d length  %d units' % (self.length, self.units)

cdef class Date:
    """ This class provides methods to inspect dates as well as methods and
    operators which implement a limited date algebra (increasing and decreasing
    dates, and calculating their difference).

    """

    def __cinit__(self, *args):

        if len(args) == 0:
            self._thisptr = new shared_ptr[QlDate](new QlDate())
        elif len(args) == 3:
            day, month, year = args
            self._thisptr = new shared_ptr[QlDate](new QlDate(<Integer>day, <_date.Month>month, <Year>year))
        elif len(args) == 1:
            serial = args[0]
            self._thisptr = new shared_ptr[QlDate](new QlDate(<BigInteger> serial))
        else:
            raise RuntimeError('Invalid constructor')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    property month:
        def __get__(self):
            return self._thisptr.get().month()

    property day:
        def __get__(self):
            return self._thisptr.get().dayOfMonth()

    property year:
        def __get__(self):
            return self._thisptr.get().year()

    property serial:
        def __get__(self):
            return self._thisptr.get().serialNumber()

    property weekday:
        def __get__(self):
            return self._thisptr.get().weekday()

    #: Day of the year (one based - Jan 1st = 1)
    property day_of_year:
        def __get__(self):
            return self._thisptr.get().dayOfYear()

    def __str__(self):
        # fixme: cannot find an easy way to get the << operator usable here
        return '%2d/%02d/%2d' % (self._thisptr.get().dayOfMonth(),
                self._thisptr.get().month(), self._thisptr.get().year())

    def __repr__(self):
        return self.__str__()

    def __hash__(self):
        # Returns a hash based on the serial
        return self.serial

    def __cmp__(self, date2):
        if isinstance(date2, (datetime.date, datetime.datetime)):
            date2 = Date.from_datetime(date2)
        elif not isinstance(date2, Date):
            return NotImplemented

        if self.serial < date2.serial:
            return -1
        elif self.serial == date2.serial:
            return 0
        else:
            return 1


    def __richcmp__(self, date2, int t):

        if isinstance(date2, (datetime.date, datetime.datetime)):
            date2 = Date.from_datetime(date2)
        elif not isinstance(date2, Date):
            return NotImplemented

        # fixme : operations done on the Python objects, could probably be
        # done faster on the C++ int directly ?
        if t==0:
            return self.serial < date2.serial
        elif t==1:
            return self.serial <= date2.serial
        elif t==2:
            return self.serial == date2.serial
        elif t==3:
            return self.serial != date2.serial
        elif t==4:
            return self.serial > date2.serial
        elif t==5:
            return self.serial >= date2.serial

        return False

    def __int__(self):
        '''Conversion to int returns the serial value
        '''
        return self._thisptr.get().serialNumber()

    def __add__(self, value):
        cdef QlDate add
        if isinstance(self, Date):
            if isinstance(value, Period):
                add = deref((<Date>self)._thisptr.get()) + deref((<Period>value)._thisptr.get())
            else:
                add = deref((<Date>self)._thisptr.get()) + <BigInteger>value
            return date_from_qldate(add)
            #d = Date()
            #d._set_qldate(add)
            #return d
        else:
            return NotImplemented

    def __iadd__(self, value):
        cdef QlDate add
        if isinstance(self, Date):
            if isinstance(value, Period):
                add = self._thisptr.get().i_add(deref((<Period>value)._thisptr.get()))
            else:
                add = self._thisptr.get().i_add(<BigInteger>value)
            return self
        else:
            return NotImplemented

    def __sub__(self, value):
        cdef QlDate sub
        if isinstance(self, Date):
            if isinstance(value, Period):
                sub = deref((<Date>self)._thisptr.get()) - deref((<Period>value)._thisptr.get())
            elif isinstance(value, int):
                sub = deref((<Date>self)._thisptr.get()) - <BigInteger>value
            else:
                raise ValueError('Unsupported operand')
            return date_from_qldate(sub)
        else:
            return NotImplemented

    def __isub__(self, value):
        cdef QlDate sub
        if isinstance(self, Date):
            if isinstance(value, Period):
                self._thisptr.get().i_sub( deref((<Period>value)._thisptr.get()) )
            else:
                self._thisptr.get().i_sub( <BigInteger>value)
            return self
        else:
            return NotImplemented

    @classmethod
    def from_datetime(cls, date):
        """Returns the Quantlib Date object from the date/datetime object. """

        return Date(date.day, date.month, date.year)

def today():
    '''Today's date. '''
    cdef QlDate today = Date_todaysDate()
    return date_from_qldate(today)

def next_weekday(Date date, int weekday):
    ''' Returns the next given weekday following or equal to the given date
    '''
    cdef QlDate nwd = Date_nextWeekday( deref(date._thisptr.get()), <_date.Weekday>weekday)
    return date_from_qldate(nwd)

def nth_weekday(int size, int weekday, int month, int year):
    '''Return the n-th given weekday in the given month and year

    E.g., the 4th Thursday of March, 1998 was March 26th, 1998.

    see http://www.cpearson.com/excel/DateTimeWS.htm
    '''
    cdef QlDate nwd = Date_nthWeekday(<Size>size, <_date.Weekday>weekday, <_date.Month>month, <Year>year)
    return date_from_qldate(nwd)

def end_of_month(Date date):
    '''Last day of the month to which the given date belongs.'''
    cdef QlDate eom = Date_endOfMonth(deref(date._thisptr.get()))
    return date_from_qldate(eom)

def maxdate():
    '''Latest allowed date.'''
    cdef QlDate mdate = Date_maxDate()
    return date_from_qldate(mdate)

def mindate():
    '''Earliest date allowed.'''
    cdef QlDate mdate = Date_minDate()
    return date_from_qldate(mdate)

def is_end_of_month(Date date):
    '''Whether a date is the last day of its month.'''
    return Date_isEndOfMonth(deref(date._thisptr.get()))

def is_leap(int year):
    '''Whether the given year is a leap one.'''
    return Date_isLeap(<Year> year)

cdef Date date_from_qldate(QlDate& date):
    '''Converts a QuantLib::Date (QlDate) to a cython Date instance.

    Inefficient because taking a copy of the date ... but safe!
    '''
    return Date(date.serialNumber())


# Date Interfaces

cdef object _pydate_from_qldate(QlDate qdate):
    """ Converts a QuantLib Date (C++) to a datetime.date object. """

    cdef int m = qdate.month()
    cdef int d = qdate.dayOfMonth()
    cdef int y = qdate.year()

    return datetime.date(y, m, d)

cpdef object pydate_from_qldate(Date qdate):
    """ Converts a PyQL Date to a datetime.date object. """

    cdef int m = qdate.month
    cdef int d = qdate.day
    cdef int y = qdate.year

    return datetime.date(y, m, d)

cdef QlDate _qldate_from_pydate(object pydate):
    """ Converts a datetime.date to a QuantLib (C++) object. """

    cdef Date qdate_ref = Date.from_datetime(pydate)
    cdef QlDate* date_ref = <QlDate*>qdate_ref._thisptr.get()

    return deref(date_ref)


cpdef Date qldate_from_pydate(object pydate):
    """ Converts a datetime.date to a PyQL date. """

    cdef Date qdate_ref = Date.from_datetime(pydate)

    return qdate_ref



