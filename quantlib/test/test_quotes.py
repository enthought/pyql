from .unittest_tools import unittest

from quantlib.quotes import SimpleQuote


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
