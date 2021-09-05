import datetime

from .unittest_tools import unittest

from quantlib.time.date import (
    Date, Jan, Feb, Mar, Apr, May, Jun, Jul, Sep, Nov, Thursday, Friday,
    Period,
    Annual, Semiannual, Bimonthly, EveryFourthMonth, Months, Years, Weeks,
    Days, OtherFrequency, end_of_month, is_end_of_month, is_leap,
    next_weekday, nth_weekday, today, pydate_from_qldate, qldate_from_pydate,
    local_date_time
)

import quantlib.time.imm as imm
from datetime import date


class TestQuantLibDate(unittest.TestCase):

    def test_today(self):

        py_today = datetime.date.today()

        ql_today = today()

        self.assertEqual(py_today.day, ql_today.day)
        self.assertEqual(py_today.month, ql_today.month)
        self.assertEqual(py_today.year, ql_today.year)

        py_now = datetime.datetime.now()
        ql_datetime = local_date_time()
        self.assertAlmostEqual(Date.from_datetime(py_now), ql_datetime)

    def test_date_empty_initialisation(self):

        date1 = Date()
        self.assertTrue(date1 is not None)

    def test_date_creation(self):

        date1 = Date(19, Nov, 1998)
        self.assertEqual(11, date1.month)

        date2 = Date(29, Feb, 2008)
        self.assertEqual(2, date2.month)

        with self.assertRaises(RuntimeError):
            # getting an invalid day
            date2 = Date(29, Feb, 2009)

        date1 = Date('2017-08-18')
        date2 = Date(18, 8, 2017)
        self.assertEqual(date1, date2)

        date2 = Date(str(date1), "%m/%d/%Y")
        self.assertEqual(date1, date2)

    def test_from_datetime_classmethod(self):

        date1 = Date(19, Nov, 1998)

        datetime_date = datetime.date(1998, 11, 19)
        from_datetime_date = Date.from_datetime(datetime_date)
        self.assertEqual(from_datetime_date.serial, date1.serial)

        datetime_datetime = datetime.datetime(1998, 11, 19, 0o1, 00)
        from_datetime_datetime = Date.from_datetime(datetime_datetime)
        self.assertEqual(from_datetime_datetime.serial, date1.serial)

    def test_comparison_with_datetime(self):

        date_nov_98 = Date(19, Nov, 1998)
        datetime_date_nov_98 = datetime.date(1998, 11, 19)

        self.assertTrue(date_nov_98 == datetime_date_nov_98)
        self.assertFalse(date_nov_98 > datetime_date_nov_98)

        datetime_date_oct_98 = datetime.date(1998, 10, 19)
        self.assertGreater(date_nov_98, datetime_date_oct_98)

    def test_equality(self):
        date1 = Date(1, 1, 2011)
        date2 = Date(1, 1, 2011)
        date3 = datetime.date(2011, 1, 1)

        self.assertEqual(date1, date2)

        self.assertEqual(date1, date3)

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

        # subtraction
        date1 = Date(19, Nov, 1998)
        date3 = date1 - 5
        expected_date = Date(14, Nov, 1998)
        self.assertTrue(expected_date == date3)

        with self.assertRaises(TypeError):
            # invalid operation
            date3 - "pomme"

        self.assertTrue(date3 - date1, 5)

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

        self.assertEqual(date1.serial, int(date1))


class ConversionMethodsTestCase(unittest.TestCase):

    def test_conversion_from_datetime_to_pyql(self):

        date1 = datetime.date(2010, 1, 1)

        qldate1 = qldate_from_pydate(date1)

        expected_result = Date(1, Jan, 2010)

        self.assertEqual(expected_result, qldate1)

    def test_conversion_from_pyql_to_datetime(self):

        date1 = Date(1, Jan, 2010)

        pydate1 = pydate_from_qldate(date1)

        expected_result = datetime.date(2010, 1, 1)

        self.assertEqual(expected_result, pydate1)


class TestQuantLibPeriod(unittest.TestCase):

    def test_creation_with_frequency(self):

        period = Period(Annual)

        self.assertEqual(1, period.length)
        self.assertEqual(Years, period.units)

        period = Period(Bimonthly)

        self.assertEqual(2, period.length)
        self.assertEqual(Months, period.units)

    def test_normalize_period(self):

        period = Period(12, Months)

        period.normalize()

        self.assertEqual(1, period.length)
        self.assertEqual(Years, period.units)

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

        self.assertEqual(10, period.length)
        self.assertEqual(Months, period.units)
        self.assertEqual(OtherFrequency, period.frequency)

    def test_creation_with_string(self):
        period1 = Period("3M")
        period2 = Period("3m")
        period3 = Period(3, Months)
        self.assertEqual(period1, period2)
        self.assertEqual(period1, period3)

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

    def test_period_subtraction(self):

        period1 = Period(11, Months)
        period2 = Period(EveryFourthMonth)

        period3 = period1 - period2
        self.assertEqual(7, period3.length)
        self.assertEqual(Months, period3.units)
        with self.assertRaisesRegexp(RuntimeError, 'impossible addition'):
            period1 - Period('3W')
        self.assertEqual(-Period('3M') + Period('6M'), Period('3M'))

    def test_period_addition(self):
        period1 = Period(4, Months)
        period2 = Period(7, Months)
        self.assertEqual(period1+period2, Period(11, Months))
        with self.assertRaisesRegexp(RuntimeError, 'impossible addition'):
            period1 + Period('2W')

    def test_multiplication(self):

        period = Period(Bimonthly)

        period2 = period * 10
        self.assertEqual(20, period2.length)

        # invert operation
        period2 = 10 * period
        self.assertIsInstance(period2, Period)
        self.assertEqual(20, period2.length)
        self.assertEqual(3 * Months, Period(3, Months))
        self.assertEqual(Days * 10, Period(10, Days))

    def test_inplace_addition(self):

        period = Period(Bimonthly)

        period2 = Period(2, Months)

        period += period2

        self.assertEqual(4, period.length)
        self.assertEqual(Months, period.units)

        with self.assertRaises(ValueError):
            period3 = Period(2, Weeks)
            period += period3  # does not support different units

    def test_inplace_subtraction(self):

        period = Period(Semiannual)

        period2 = Period(3, Months)

        period -= period2

        self.assertEqual(3, period.length)
        self.assertEqual(Months, period.units)

        with self.assertRaises(ValueError):
            period3 = Period(2, Weeks)
            period -= period3  # does not support different units

    def test_inplace_division(self):

        period = Period(Semiannual)

        period /= 3

        self.assertEqual(2, period.length)
        self.assertEqual(Months, period.units)

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

class TestQuantLibIMM(unittest.TestCase):

    def test_is_imm_date(self):

        dt = Date(17, Sep, 2014)
        is_imm = imm.is_IMM_date(dt)
        self.assertTrue(is_imm)

        dt = Date(18, Sep, 2014)
        is_imm = imm.is_IMM_date(dt)
        self.assertFalse(is_imm)

    def test_is_imm_code(self):

        is_good = imm.is_IMM_code('H9')
        self.assertTrue(is_good)

        is_bad = imm.is_IMM_code('WX')
        self.assertFalse(is_bad)

    def test_imm_date(self):
        dt = imm.date('M9')
        cd = imm.code(dt)
        self.assertEqual(cd, 'M9')

    def test_next_date(self):
        dt = Date(19, Jun, 2014)
        dt_2 = imm.next_date(dt)
        # 17 sep 2014
        self.assertEqual(dt_2, date(2014, 9, 17))

        dt_3 = imm.next_date('M9', True, Date(1, 6, 2019))
        # 18 sep 2019
        self.assertEqual(dt_3, date(2019, 9, 18))

    def test_next_code(self):
        dt = Date(10, Jun, 2014)
        cd_2 = imm.next_code(dt)
        # M4
        self.assertEqual(cd_2, "M4")

        cd_3 = imm.next_code('M9', True, today())
        # U9
        self.assertEqual(cd_3, "U9")
