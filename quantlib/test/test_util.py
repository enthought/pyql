import datetime
import unittest

from quantlib.time.date import (
    Date, Jan, Feb, Mar, Apr, May, Jun, Jul, Nov, Thursday, Friday, Period,
    Annual, Semiannual, Bimonthly, EveryFourthMonth, Months, Years, Weeks,
    Days, OtherFrequency, end_of_month, is_end_of_month, is_leap,
    next_weekday, nth_weekday, today, pydate_from_qldate, qldate_from_pydate
)

from quantlib.util.converter import pydate_to_qldate


class TestUtil(unittest.TestCase):

    def test_converter_1(self):
        ql_today_1 = today()
        py_today = datetime.date.today()
        ql_today_2 = pydate_to_qldate(py_today)

        self.assertEquals(ql_today_1.day, ql_today_2.day)
        self.assertEquals(ql_today_1.month, ql_today_2.month)
        self.assertEquals(ql_today_1.year, ql_today_2.year)

    def test_converter_2(self):

        ql_1 = Date(20, Nov, 2005)
        ql_2 = pydate_to_qldate('20Nov2005')

        self.assertEquals(ql_1.day, ql_2.day)
        self.assertEquals(ql_1.month, ql_2.month)
        self.assertEquals(ql_1.year, ql_2.year)

    def test_converter_2(self):

        ql_1 = Date(20, Nov, 2005)
        ql_2 = pydate_to_qldate('20Nov2005')

        self.assertEquals(ql_1.day, ql_2.day)
        self.assertEquals(ql_1.month, ql_2.month)
        self.assertEquals(ql_1.year, ql_2.year)

if __name__ == '__main__':
    unittest.main()

