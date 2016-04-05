"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from __future__ import print_function

import locale
import re
import datetime

import six
from quantlib.time import Date, Actual365Fixed
import quantlib.time.date as dt
from quantlib.termstructures.yields.zero_curve import ZeroCurve

_dayOfWeekName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
                  'Friday', 'Saturday', 'Sunday']
_monthName = ['January', 'February', 'March', 'April', 'May',
              'June', 'July', 'August', 'September', 'October',
              'November', 'December']
_shortMonthName = ['jan', 'feb', 'mar', 'apr', 'may', 'jun',
                   'jul', 'aug', 'sep', 'oct', 'nov', 'dec']


date_re_list = [ \
    # Styles: (1)
    (re.compile("([0-9]+)-([A-Za-z]+)-([0-9]{2,4})"),
     (3, 2, 1)),
    # Styles: (2)
    (re.compile("([0-9]{4,4})([0-9]{2,2})([0-9]{2,2})"),
     (1, 2, 3)),
    # Styles: (3)
    (re.compile("([0-9]+)/([0-9]+)/([0-9]{2,4})"),
     (2, 1, 3)),
    # Styles: (4)
    (re.compile("([0-9](1,2))([A-Za-z](3,3))([0-9](2,4))"),
     (3, 2, 1)),
    # Styles: (5)
    (re.compile("([0-9]{2,4})-([0-9]+)-([0-9]+)"),
     (1, 2, 3))]

DAYS = 1
MONTHS = 2
YEARS = 3


def _partition_date(date):
    """
    Partition a date string into three sub-strings
    year, month, day

    The following styles are understood:
    (1) 22-AUG-1993 or
        22-Aug-03 (2000+yy if yy<50)
    (2) 20010131
    (3) mm/dd/yy or
        mm/dd/yyyy
    (4) 10Aug2004 or
        10Aug04
    (5) yyyy-mm-dd
    """

    date = str.lstrip(str.rstrip(date))
    for reg, idx in date_re_list:
        mo = reg.match(date)
        if mo != None:
            return (mo.group(idx[0]), mo.group(idx[1]),
                    mo.group(idx[2]))

    raise Exception("couldn't partition date: %s" % date)


def _parsedate(date):
    """
    Parse a date string and return the tuple
    (year, month, day)
    """
    (yy, mo, dd) = _partition_date(date)
    if len(yy) == 2:
        yy = locale.atoi(yy)
        yy += 2000 if yy < 50 else 1900
    else:
        yy = locale.atoi(yy)

    try:
        mm = locale.atoi(mo)
    except:
        mo = str.lower(mo)
        if not mo in _shortMonthName:
            raise Exception("Bad month name: " + mo)
        else:
            mm = _shortMonthName.index(mo) + 1

    dd = locale.atoi(dd)
    return (yy, mm, dd)


def pydate(date):
    """
    Accomodate date inputs as string or python date
    """

    if isinstance(date, datetime.datetime):
        return date
    else:
        yy, mm, dd = _parsedate(date)
        return datetime.datetime(yy, mm, dd)


def pydate_to_qldate(date):
    """
    Converts a datetime object or a date string
    into a QL Date.
    """

    if isinstance(date, Date):
        return date
    if isinstance(date, six.string_types):
        yy, mm, dd = _parsedate(date)
        return Date(dd, mm, yy)
    else:
        return dt.qldate_from_pydate(date)


def qldate_to_pydate(date):
    """
    Converts a QL Date to a datetime
    """

    return datetime.datetime(date.year, date.month, date.day)


def df_to_zero_curve(rates, settlement_date, daycounter=Actual365Fixed()):
    """ Converts a pandas data frame into a QL zero curve. """

    dates = [pydate_to_qldate(dt) for dt in rates.index]
    dates.insert(0, pydate_to_qldate(settlement_date))

    # arbitrarily extend the curve a few years to provide flat
    # extrapolation
    dates.append(dates[-1] + 365 * 2)

    values = rates.values.tolist()
    values.insert(0, values[0])
    values.append(values[-1])

    return ZeroCurve(dates, values, daycounter)
