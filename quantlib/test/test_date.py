import datetime

from .unittest_tools import unittest

from quantlib.time.date import (
    Date, Jan, Feb, Mar, Apr, May, Jun, Jul, Nov, Thursday, Friday, Period,
    Annual, Semiannual, Bimonthly, EveryFourthMonth, Months, Years, Weeks,
    Days, OtherFrequency, end_of_month, is_end_of_month, is_leap,
    next_weekday, nth_weekday, today, pydate_from_qldate, qldate_from_pydate
)


class TestQuantLibDate(unittest.TestCase):

    def test_today(self):

        py_today = datetime.date.today()

        ql_today = today()

        self.assertEquals(py_today.day, ql_today.day)
        self.assertEquals(py_today.month, ql_today.month)
        self.assertEquals(py_today.year, ql_today.year)

    def test_date_empyt_initialisation(self):

        date1 = Date()
        self.assertTrue(date1 is not None)

    def test_date_creation(self):

        date1 = Date(19, Nov, 1998)
        self.assertEquals(11, date1.month)

        date2 = Date(29, Feb, 2008)
        self.assertEquals(2, date2.month)

        with self.assertRaises(RuntimeError):
            # getting an invalid day
            date2 = Date(29, Feb, 2009)

    def test_from_datetime_classmethod(self):

        date1 = Date(19, Nov, 1998)

        datetime_date = datetime.date(1998, 11, 19)
        from_datetime_date = Date.from_datetime(datetime_date)
        self.assertEquals(from_datetime_date.serial, date1.serial)

        datetime_datetime = datetime.datetime(1998, 11, 19, 0o1, 00)
        from_datetime_datetime = Date.from_datetime(datetime_datetime)
        self.assertEquals(from_datetime_datetime.serial, date1.serial)

    def test_comparison_with_datetime(self):

        date_nov_98 = Date(19, Nov, 1998)
        datetime_date_nov_98 = datetime.date(1998, 11, 19)

        self.assertTrue(date_nov_98 == datetime_date_nov_98)
        self.assertEquals(cmp(date_nov_98, datetime_date_nov_98), 0)

        datetime_date_oct_98 = datetime.date(1998, 10, 19)
        self.assertTrue(date_nov_98 > datetime_date_oct_98)

    def test_equality(self):
        date1 = Date(1, 1, 2011)
        date2 = Date(1, 1, 2011)
        date3 = datetime.date(2011, 1, 1)

        self.assertEquals(date1, date2)

        self.assertEquals(date1, date3)

    def test_arithmetic_operators(self):

        # addition
        date1 = Date(19, Nov, 1998)
        date2 = date1 + 5
        expected_date = Date(24, Nov, 1998)
        self.assertTrue(expected_date == date2)

        # iadd
        date1 = Date(19, Nov, 1998)
        date1 += 3
        expected_date = Date(22, Nov, 1998)
        self.assertTrue(expected_date == date1)

        # substraction
        date1 = Date(19, Nov, 1998)
        date3 = date1 - 5
        expected_date = Date(14, Nov, 1998)
        self.assertTrue(expected_date == date3)

        with self.assertRaises(ValueError):
            # invalid operation
            date3 - date1

        # isub
        date1 = Date(19, Nov, 1998)
        date1 -= 3
        expected_date = Date(16, Nov, 1998)
        self.assertTrue(expected_date == date1)

    def test_next_weekday(self):
        ''' Test next weekday

        The Friday following Tuesday, January 15th, 2002 was
        January 18th, 2002.
        see http://www.cpearson.com/excel/DateTimeWS.htm
        '''

        date1 = Date(15, Jan, 2002)
        date2 = next_weekday(date1, Friday)

        expected_date = Date(18, Jan, 2002)
        self.assertTrue(expected_date == date2)

    def test_nth_weekday(self):
        ''' The 4th Thursday of Mar, 1998 was Mar 26th, 1998.
        see http://www.cpearson.com/excel/DateTimeWS.htm
        '''

        date1 = nth_weekday(4, Thursday, Mar, 1998)

        expected_date = Date(26, Mar, 1998)
        self.assertTrue(expected_date == date1)

    def test_nth_weekday_invalid_month(self):

        with self.assertRaises(RuntimeError):
            nth_weekday(4, Thursday, 0, 2000)

    def test_end_of_month(self):

        date1 = Date(16, Feb, 2011)
        date2 = end_of_month(date1)
        expected_date = Date(28, Feb, 2011)
        self.assertTrue(expected_date == date2)

    def test_is_end_of_month(self):

        date1 = Date(28, Feb, 2011)

        self.assertTrue(is_end_of_month(date1))

    def test_is_leap(self):

        self.assertTrue(is_leap(2008))
        self.assertFalse(is_leap(2009))

    def test_convertion_to_integer(self):

        date1 = Date(28, Feb, 2011)

        self.assertEquals(date1.serial, int(date1))


class ConversionMethodsTestCase(unittest.TestCase):

    def test_conversion_from_datetime_to_pyql(self):

        date1 = datetime.date(2010, 1, 1)

        qldate1 = qldate_from_pydate(date1)

        expected_result = Date(1, Jan, 2010)

        self.assertEquals(expected_result, qldate1)

    def test_conversion_from_pyql_to_datetime(self):

        date1 = Date(1, Jan, 2010)

        pydate1 = pydate_from_qldate(date1)

        expected_result = datetime.date(2010, 1, 1)

        self.assertEquals(expected_result, pydate1)


class TestQuantLibPeriod(unittest.TestCase):

    def test_creation_with_frequency(self):

        period = Period(Annual)

        self.assertEquals(1, period.length)
        self.assertEquals(Years, period.units)

        period = Period(Bimonthly)

        self.assertEquals(2, period.length)
        self.assertEquals(Months, period.units)

    def test_normalize_period(self):

        period = Period(12, Months)

        period.normalize()

        self.assertEquals(1, period.length)
        self.assertEquals(Years, period.units)

    def test_rich_cmp(self):

        # equality
        period1 = Period(Annual)
        period2 = Period(1, Years)
        self.assertTrue(period1 == period2)

        period1 = Period(12, Months)
        period2 = Period(1, Years)
        self.assertTrue(period1 == period2)

        # non equality
        period1 = Period(11, Months)
        period2 = Period(1, Years)
        period3 = Period(150, Weeks)
        period4 = Period(52, Weeks)

        self.assertTrue(period1 != period2)
        self.assertTrue(period1 < period2)
        self.assertTrue(period3 > period1)
        self.assertTrue(period3 >= period1)
        self.assertTrue(period4 <= period2)

    def test_creation_with_time_and_units(self):

        period = Period(10, Months)

        self.assertEquals(10, period.length)
        self.assertEquals(Months, period.units)
        self.assertEquals(OtherFrequency, period.frequency)

    def test_adding_period_to_date(self):

        date1 = Date(1, May, 2011)

        period = Period(1, Months)
        date2 = date1 + period
        expected_date = Date(1, Jun, 2011)
        self.assertTrue(expected_date == date2)

        period = Period(Bimonthly)
        date2 = date1 + period
        expected_date = Date(1, Jul, 2011)
        self.assertTrue(expected_date == date2)

        period = Period(10, Months)
        date2 = date1 + period
        expected_date = Date(1, Mar, 2012)
        self.assertTrue(expected_date == date2)

    def test_period_substraction(self):

        period1 = Period(11, Months)
        period2 = Period(EveryFourthMonth)

        period3 = period1 - period2
        self.assertEquals(7, period3.length)
        self.assertEquals(Months, period3.units)

    def test_multiplication(self):

        period = Period(Bimonthly)

        period2 = period * 10
        self.assertEquals(20, period2.length)

        # invert operation
        period2 = 10 * period
        self.assertIsInstance(period2, Period)
        self.assertEquals(20, period2.length)

    def test_inplace_addition(self):

        period = Period(Bimonthly)

        period2 = Period(2, Months)

        period += period2

        self.assertEquals(4, period.length)
        self.assertEquals(Months, period.units)

        with self.assertRaises(ValueError):
            period3 = Period(2, Weeks)
            period += period3  # does not support different units

    def test_inplace_substraction(self):

        period = Period(Semiannual)

        period2 = Period(3, Months)

        period -= period2

        self.assertEquals(3, period.length)
        self.assertEquals(Months, period.units)

        with self.assertRaises(ValueError):
            period3 = Period(2, Weeks)
            period -= period3  # does not support different units

    def test_inplace_division(self):

        period = Period(Semiannual)

        period /= 3

        self.assertEquals(2, period.length)
        self.assertEquals(Months, period.units)

    def test_substracting_period_to_date(self):

        date1 = Date(1, May, 2011)

        period = Period(1, Months)
        date2 = date1 - period
        expected_date = Date(1, Apr, 2011)
        self.assertTrue(expected_date == date2)

        period = Period(Bimonthly)
        date2 = date1 - period
        expected_date = Date(1, Mar, 2011)
        self.assertTrue(expected_date == date2)

        period = Period(10, Days)
        date2 = date1 - period
        expected_date = Date(21, Apr, 2011)
        self.assertTrue(expected_date == date2)
