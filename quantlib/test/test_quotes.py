from .unittest_tools import unittest

from quantlib.quotes import SimpleQuote, FuturesConvAdjustmentQuote
from quantlib.indexes.api import USDLibor
from quantlib.time.api import Period, Months, Date
from quantlib.settings import Settings

class SimpleQuoteTestCase(unittest.TestCase):

    def test_round_trip(self):

        value = 72.03
        quote = SimpleQuote(value)
        self.assertAlmostEqual(value, quote.value)

    def test_empty_constructor(self):
        quote = SimpleQuote()
        self.assertFalse(quote.is_valid)
        with self.assertRaisesRegexp(RuntimeError, 'invalid SimpleQuote'):
            x = quote.value
        # test quote reset
        quote.value = 1.
        quote.reset()
        self.assertFalse(quote.is_valid)
        with self.assertRaisesRegexp(RuntimeError, 'invalid SimpleQuote'):
            x = quote.value

class FuturesConvAdjustmentTestCase(unittest.TestCase):

    def setUp(self):
        self.mean_reversion = SimpleQuote(0.03)
        self.volatility = SimpleQuote(0.00714)
        self.index = USDLibor(Period(3, Months))
        self.quote = SimpleQuote(99.375)
        Settings().evaluation_date = Date(13, 10, 2021)
        self.fut_quote = FuturesConvAdjustmentQuote(self.index, "Z2", self.quote, self.volatility, self.mean_reversion)

    def test_construction(self):
        self.assertEqual(self.fut_quote.volatility, self.volatility.value)
        self.assertEqual(self.fut_quote.mean_reversion, self.mean_reversion.value)
        self.assertEqual(self.fut_quote.futures_value, self.quote.value)
        imm_date = Date(21, 12, 2022)
        self.assertEqual(self.fut_quote.imm_date, imm_date)
        last_date = Date(10, 12, 2022)
        fut_quote = FuturesConvAdjustmentQuote(self.index, last_date, self.quote, self.volatility, self.mean_reversion)
        self.assertEqual(fut_quote.imm_date, last_date)

    def test_conv_quote(self):
        self.assertAlmostEqual(self.fut_quote.value, 5.039*1e-5)

    def test_update(self):
        self.quote.value = 99.25
        self.mean_reversion.value = 0.04
        self.assertAlmostEqual(self.fut_quote.value, 4.9726955*1e-5)
