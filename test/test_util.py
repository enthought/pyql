import datetime

import unittest
from quantlib.time.date import Date, Nov, today

from quantlib.util.converter import pydate_to_qldate


class TestUtil(unittest.TestCase):

    def test_converter_1(self):
        ql_today_1 = today()
        py_today = datetime.date.today()
        ql_today_2 = pydate_to_qldate(py_today)

        self.assertEqual(ql_today_1.day, ql_today_2.day)
        self.assertEqual(ql_today_1.month, ql_today_2.month)
        self.assertEqual(ql_today_1.year, ql_today_2.year)

    def test_converter_2(self):

        ql_1 = Date(20, Nov, 2005)
        ql_2 = pydate_to_qldate('20-Nov-2005')

        self.assertEqual(ql_1.day, ql_2.day)
        self.assertEqual(ql_1.month, ql_2.month)
        self.assertEqual(ql_1.year, ql_2.year)

    def test_converter_2(self):

        ql_1 = Date(20, Nov, 2005)
        ql_2 = pydate_to_qldate('20-Nov-2005')

        self.assertEqual(ql_1.day, ql_2.day)
        self.assertEqual(ql_1.month, ql_2.month)
        self.assertEqual(ql_1.year, ql_2.year)

if __name__ == '__main__':
    unittest.main()

