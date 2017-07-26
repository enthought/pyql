from .unittest_tools import unittest

from quantlib.time.date import Date
import quantlib.cashflow as cf
from datetime import date


class TestQuantLibDate(unittest.TestCase):

    def test_simple_cashflow(self):

        cf_date = Date(1, 7, 2030)
        cf_amount = 100.0

        test_cf = cf.SimpleCashFlow(cf_amount, cf_date)

        self.assertEqual(test_cf.amount, cf_amount)
        self.assertEqual(test_cf.date, cf_date)

    def test_leg(self):

        cf_date = Date(1, 7, 2030)
        pydate = date(2030, 7, 1)
        cf_amount = 100.0

        leg = ((cf_amount, cf_date),)

        test_leg = cf.Leg(leg)
        self.assertEqual(len(test_leg), 1)
        self.assertEqual(list(test_leg), [(100.0, pydate)])
